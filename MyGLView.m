//
//  MyGLView.m
//  OpenGL1
//
//  Created by Mark Herman, II on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

// Adapting code from http://www.lighthouse3d.com/cg-topics/code-samples/opengl-3-3-glsl-1-5-sample/

// This seems to be the best place to find keyboard codes
#import "HIToolbox/Events.h"

#import "MyGLView.h"
#import "Shader.h"

#include "matrix_functions.h"

static const GLfloat pyramidTriangleVertices[] =
{
    0.0f, 1.0f, 0.0f, 1.0f,
    -1.0f, -1.0f, 1.0f, 1.0f,
    1.0f, -1.0f, 1.0f, 1.0f,
    
    0.0f, 1.0f, 0.0f, 1.0f,
    1.0f, -1.0f, 1.0f, 1.0f,
    1.0f, -1.0f, -1.0f, 1.0f,
    
    0.0f, 1.0f, 0.0f, 1.0f,
    1.0f, -1.0f, -1.0f, 1.0f,
    -1.0f, -1.0f, -1.0f, 1.0f,
    
    0.0f, 1.0f, 0.0f, 1.0f,
    -1.0f, -1.0f, -1.0f, 1.0f,
    -1.0f, -1.0f, 1.0f, 1.0f
};

static const GLfloat pyramidTriangleColors[] = {
    0.0f, 1.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, 1.0f,
    
    0.0f, 1.0f, 0.0f,
    1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, -1.0f,
    
    0.0f, 1.0f, 0.0f,
    1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
    
    0.0f, 1.0f, 0.0f,
    -1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f, 1.0f
};

static const GLfloat pyramidQuadVertices[] =
{
    -1.0f, -1.0f, 1.0f, 1.0f,
    1.0f, -1.0f, 1.0f, 1.0f,
    1.0f, -1.0f, -1.0f, 1.0f,
    -1.0f, -1.0f, -1.0f, 1.0f
};

static const GLfloat pyramidQuadColors[] =
{
    1.0f, 1.0f, 1.0f
};

// Data for drawing Axis
float verticesAxis[] = {-20.0f, 0.0f, 0.0f, 1.0f,
    20.0f, 0.0f, 0.0f, 1.0f,
    
    0.0f, -20.0f, 0.0f, 1.0f,
    0.0f,  20.0f, 0.0f, 1.0f,
    
    0.0f, 0.0f, -20.0f, 1.0f,
    0.0f, 0.0f,  20.0f, 1.0f};

float colorAxis[] = {   0.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 0.0f};

// storage for Matrices
float projMatrix[16];
float viewMatrix[16];

// Vertex Attribute Locations
GLuint vertexLoc, colorLoc;

GLuint shaderProg;

// VAO Identifiers
GLuint pyramidVerticesVAO, pyramidQuadVerticesVAO, axisVAO;

// storage for Matrix uniforms
GLuint projMatrixLoc, viewMatrixLoc;

int windowResized = 0;  // Flag to indicate viewport needs to be reset

#define INIT_COUNTER_VALUE 1
float counter = INIT_COUNTER_VALUE;
int counterDirection = 0;   // This will flip between 0 and 1

void logOpenGlError(NSString* whatYouAreDoing) {
    switch (glGetError()) {
        case GL_INVALID_ENUM:
            NSLog(@"Invalid enum returned while %@", whatYouAreDoing);
            break;
        case GL_INVALID_VALUE:
            NSLog(@"Invalid value returned while %@", whatYouAreDoing);
            break;
        case GL_INVALID_OPERATION:
            NSLog(@"Invalid operation returned while %@", whatYouAreDoing);
            break;
        case GL_OUT_OF_MEMORY:
            NSLog(@"Out of memory returned while %@", whatYouAreDoing);
            break;
        case GL_INVALID_FRAMEBUFFER_OPERATION:
            NSLog(@"Invalid framebuffer operation returned while %@", whatYouAreDoing);
            break;
        case GL_NO_ERROR:
            NSLog(@"No error returned while %@", whatYouAreDoing);
    }
}

// ----------------------------------------------------
// Projection Matrix
//

void buildProjectionMatrix(float fov, float ratio, float nearP, float farP) {
    
    float f = 1.0f / tan (fov * (M_PI / 360.0));
    
    setIdentityMatrix(projMatrix,4);
    
    projMatrix[0] = f / ratio;
    projMatrix[1 * 4 + 1] = f;
    projMatrix[2 * 4 + 2] = (farP + nearP) / (nearP - farP);
    projMatrix[3 * 4 + 2] = (2.0f * farP * nearP) / (nearP - farP);
    projMatrix[2 * 4 + 3] = -1.0f;
    projMatrix[3 * 4 + 3] = 0.0f;
}

// ----------------------------------------------------
// View Matrix
//
// note: it assumes the camera is not tilted,
// i.e. a vertical up vector (remmeber gluLookAt?)
//

void setCamera(float posX, float posY, float posZ,
               float lookAtX, float lookAtY, float lookAtZ) {
    
    float dir[3], right[3], up[3];
    
    up[0] = 0.0f;   up[1] = 1.0f;   up[2] = 0.0f;
    
    dir[0] =  (lookAtX - posX);
    dir[1] =  (lookAtY - posY);
    dir[2] =  (lookAtZ - posZ);
    normalize(dir);
    
    crossProduct(dir,up,right);
    normalize(right);
    
    crossProduct(right,dir,up);
    normalize(up);
    
    float aux[16];
    
    viewMatrix[0]  = right[0];
    viewMatrix[4]  = right[1];
    viewMatrix[8]  = right[2];
    viewMatrix[12] = 0.0f;
    
    viewMatrix[1]  = up[0];
    viewMatrix[5]  = up[1];
    viewMatrix[9]  = up[2];
    viewMatrix[13] = 0.0f;
    
    viewMatrix[2]  = -dir[0];
    viewMatrix[6]  = -dir[1];
    viewMatrix[10] = -dir[2];
    viewMatrix[14] =  0.0f;
    
    viewMatrix[3]  = 0.0f;
    viewMatrix[7]  = 0.0f;
    viewMatrix[11] = 0.0f;
    viewMatrix[15] = 1.0f;
    
    setTranslationMatrix(aux, -posX, -posY, -posZ);
    
    multMatrix(viewMatrix, aux);
}

void changeSize(int w, int h) {
    
    float ratio;
    // Prevent a divide by zero, when window is too short
    // (you cant make a window of zero width).
    if(h == 0)
        h = 1;
    
    // Set the viewport to be the entire window
    glViewport(0, 0, w, h);
    
    ratio = (1.0f * w) / h;
    buildProjectionMatrix(53.13f, ratio, 1.0f, 30.0f);
}

void setupBuffers() {
    GLuint buffers[2];
    
    glGenVertexArrays(1, &pyramidVerticesVAO);
    glBindVertexArray(pyramidVerticesVAO);
//    // Reserve a name for the buffer object.
    glGenBuffers(2, buffers);
//    // Bind it to the GL_ARRAY_BUFFER target.
    glBindBuffer(GL_ARRAY_BUFFER, buffers[0]);
//    // Allocate space for it
    glBufferData(GL_ARRAY_BUFFER, sizeof(pyramidTriangleVertices),
                 pyramidTriangleVertices,
                 GL_STATIC_DRAW);    // usage
    glEnableVertexAttribArray(vertexLoc);
    glVertexAttribPointer(vertexLoc, 4, GL_FLOAT, 0, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, buffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(pyramidTriangleColors), pyramidTriangleColors, GL_STATIC_DRAW);
    glEnableVertexAttribArray(colorLoc);
    glVertexAttribPointer(colorLoc, 4, GL_FLOAT, 0, 0, 0);
    
    // The following works
    
    glGenVertexArrays(1, &axisVAO);
    logOpenGlError(@"glGenVertexArrays in setupBuffers()");
    
    glBindVertexArray(axisVAO);
    logOpenGlError(@"glBindVertexArray in setupBuffers()");

    glGenBuffers(2, buffers);
    logOpenGlError(@"glGenBuffers in setupBuffers()");
    glBindBuffer(GL_ARRAY_BUFFER, buffers[0]);
    logOpenGlError(@"glBindBuffer in setupBuffers()");
    glBufferData(GL_ARRAY_BUFFER, sizeof(verticesAxis),
                 verticesAxis,
                 GL_STATIC_DRAW);    // usage
    logOpenGlError(@"glBufferData in setupBuffers()");
    glVertexAttribPointer(vertexLoc, 4, GL_FLOAT, GL_FALSE, 0, 0);
    logOpenGlError(@"glVertexAttribPointer in setupBuffers()");
    glEnableVertexAttribArray(vertexLoc);
    logOpenGlError(@"glEnableVertexAttribArray in setupBuffers()");
    
    glBindBuffer(GL_ARRAY_BUFFER, buffers[1]);
    logOpenGlError(@"glBindBuffer in color setupBuffers()");
    glBufferData(GL_ARRAY_BUFFER, sizeof(colorAxis), colorAxis, GL_STATIC_DRAW);
    logOpenGlError(@"glBufferData in color setupBuffers()");
    glEnableVertexAttribArray(colorLoc);
    logOpenGlError(@"glEnableVertexAttribArray in color setupBuffers()");
    glVertexAttribPointer(colorLoc, 4, GL_FLOAT, 0, 0, 0);
    logOpenGlError(@"glVertexAttribPointer in color setupBuffers()");
}

void setUniforms() {
    // must be called after glUseProgram
    glUniformMatrix4fv(projMatrixLoc,  1, false, projMatrix);
    glUniformMatrix4fv(viewMatrixLoc,  1, false, viewMatrix);
}

@implementation MyGLView

-(void)awakeFromNib
{
    
	NSOpenGLPixelFormatAttribute attr[] = {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core, // Needed if using opengl 3.2 you can comment this line out to use the old version.
        NSOpenGLPFAColorSize,     24,
        NSOpenGLPFAAlphaSize,     8,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        0
    };
    
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attr];
    [self setPixelFormat: pixelFormat];
    NSOpenGLContext *openGLContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
    
    [self setPixelFormat: pixelFormat];
    [self setOpenGLContext: openGLContext];
    
    readyToDraw = NO;
    angle = 0;
    piover180 = M_PI / 180.0;
    player = [[Player alloc] init];
    keyState = [[KeyboardState alloc] init];
    [[self window] setAcceptsMouseMovedEvents: YES];
    
    centerPoint.x = 200;
    centerPoint.y = 200;
    
    // Load my model object from Blender
    // blenderObject = [[QuadModel alloc] init];
//    [blenderObject loadQuadsFromRawFile:"/Users/markherman/blender/learning1.raw"];
    
}

- (void)prepareOpenGL
{
    [[self openGLContext] makeCurrentContext];
    
    printf("OpenGL Version: %s\n", glGetString(GL_VERSION));
    
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
	
    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
    
    glEnable(GL_DEPTH_TEST);
    
    Shader *myVertexShader = [[Shader alloc] initWithType: GL_VERTEX_SHADER];
    [myVertexShader loadFromResourceWithName: @"SimpleShader"];
    
    Shader *myFragmentShader = [[Shader alloc] initWithType: GL_FRAGMENT_SHADER];
    [myFragmentShader loadFromResourceWithName: @"SimpleShader"];
    
    shaderProg = glCreateProgram();
    
    glAttachShader(shaderProg, [myVertexShader glShader]);
    glAttachShader(shaderProg, [myFragmentShader glShader]);
    
    glBindFragDataLocation(shaderProg, 0, "outputF");
    glLinkProgram(shaderProg);
    
    vertexLoc = glGetAttribLocation(shaderProg, "position");
    colorLoc = glGetAttribLocation(shaderProg, "color");
    
    projMatrixLoc = glGetUniformLocation(shaderProg, "projMatrix");
    viewMatrixLoc = glGetUniformLocation(shaderProg, "viewMatrix");
    
    GLint linkStatus;
    
    glGetProgramiv(shaderProg, GL_LINK_STATUS, &linkStatus);
    
    if (linkStatus == GL_TRUE) {
        NSLog(@"Shader program link succeeded");
    } else {
        NSLog(@"Shader program link failed.");
        char log[8192];
        GLsizei logLength = 0;
        glGetProgramInfoLog(shaderProg, 8192, &logLength, log);
        
        if (strlen(log) > 0) {
            fprintf(stderr, "Program info log: %s\n", log);
            fprintf(stderr, "Log length: %d\n", logLength);
        }
    }

    setupBuffers();
    
    // Activate the display link
    CVDisplayLinkStart(displayLink);
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = (CVReturn) [(MyGLView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void)setViewPortForWindow
{
    CGRect bounds = [self bounds];
    
    // From original version of this example app.
    //		gluPerspective(90.0f, bounds.size.width / bounds.size.height, 0.2f, 255.0f);
    
    glViewport(0, 0, bounds.size.width, bounds.size.height);
    
    float ratio = (1.0f * bounds.size.width) / bounds.size.height;
    buildProjectionMatrix(53.13f, ratio, 1.0f, 30.0f);
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
    // TODO: calculate distance based on how much time elapsed between frames.
    // TODO: move keyboard handling to a function
    
    // Move based on key presses
    if ([keyState keyDown: kVK_UpArrow])
        [player moveForwardDistance: 1.0f];
    
    if ([keyState keyDown: kVK_DownArrow])
        [player moveBackwardDistance: 1.0f];
    
    if ([keyState keyDown: kVK_LeftArrow])
        [player rotateLeftDegrees: 1.5f];
    
    if ([keyState keyDown: kVK_RightArrow])
        [player rotateRightDegrees: 1.5f];
    
	GLfloat x_m, y_m, z_m, u_m, v_m;				// Floating Point For Temp X, Y, Z, U And V Vertices
	GLfloat xtrans = -[player xpos];						// Used For Player Translation On The X Axis
	GLfloat ztrans = -[player zpos];						// Used For Player Translation On The Z Axis
	GLfloat ytrans = -walkbias-0.25f;				// Used For Bouncing Motion Up And Down
	GLfloat sceneroty = 360.0f - [player yrot];				// 360 Degree Angle For Player Direction
    
	
	[[self openGLContext] makeCurrentContext];
    
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	if (!readyToDraw) {
        [self setViewPortForWindow];
		readyToDraw = YES;
	}
    
    if (windowResized) {
        [self setViewPortForWindow];
        windowResized = 0;
    }

    glClearColor(1.0, 0.0, 0.0, 1.0);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (counterDirection == 0)
        counter = counter + 0.01;
    else
        counter = counter - 0.01;

    if (counter > 2.0) {
        counterDirection = 1;
    }
    if (counter < INIT_COUNTER_VALUE) {
        counterDirection = 0;
    }

    setCamera(5 * counter, 5 * counter, 5 * counter, -1, -1, -1);

    glUseProgram(shaderProg);
    setUniforms();

//    glBindBuffer(GL_ARRAY_BUFFER, axisVAO);   // This works too.
    glBindVertexArray(axisVAO);
    glDrawArrays(GL_LINES, 0, 6);
    
    glBindVertexArray(pyramidVerticesVAO);
    glDrawArrays(GL_TRIANGLES, 0, 48);

/*
	glRotatef(sceneroty,0,1.0f,0);					// Rotate Depending On Direction Player Is Facing
	glTranslatef(xtrans, ytrans, ztrans);				// Translate The Scene Based On Player Position	
*/
    
//	glRotatef(angle, angle, angle, 1.0f);
	
/*
	glTranslatef(0.0f, 0.0f, -4.0f);
	glRotatef(angle, 0.0f, 0.0f, 1.0f);
*/
	// DrawTriangle();
	
    // Scale by the slider's scale factor
    float scaleFactor = [scaleSlider floatValue];
/*
    glScalef(scaleFactor, scaleFactor, scaleFactor);
    DrawPyramid();
 
    [blenderObject draw];
*/
    /*
	glTranslatef(0.0f, 0.0f, 4.0f);
	glRotatef(-angle, 0.0f, 0.0f, 1.0f);
	
	
	glTranslatef(0.0f, 0.0f, -3.0f);
	glRotatef(-angle, 0.0f, 0.0f, 1.0f);
	
	DrawTriangle();	
    */ 
    
     
	angle += 0.5f;
	
	if (angle >= 360.0)
		angle = 0.0;

    glFlush();
	[[self openGLContext] flushBuffer];

	CGLUnlockContext([[self openGLContext] CGLContextObj]);
	
    return kCVReturnSuccess;
}

-(BOOL)acceptsFirstResponder { return YES; }
-(BOOL)becomeFirstResponder  { return YES; }
-(BOOL)resignFirstResponder  { return YES; }

- (void)reshape {
    windowResized = 1;
    [super reshape];
}

- (void) keyDown: (NSEvent *) theEvent
{
    // Ignore repeats
    if ([theEvent isARepeat])
        return;
    
    NSLog(@"Key pressed: %@\n", [theEvent characters]);
    
    /* This is from when I was interpreting scroll events for arrow key movement.
    // Arrow keys are associated with the numeric keypad
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) {
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    }
    */
    
    // Exit the app if the user presses escape
    if ([theEvent keyCode] == kVK_Escape)
            CGAssociateMouseAndMouseCursorPosition(1);  // reassociate mouse movement with the cursor.
        
    // Previous exit the app code
    // [[NSApplication sharedApplication] terminate:nil];
    
    // Set the key state to down
    [keyState setKeyDown: [theEvent keyCode]];
}

- (void) keyUp: (NSEvent *) theEvent
{
    // Ignore repeats
    if ([theEvent isARepeat])
        return;
    
    // Set the key state to up
    [keyState setKeyUp: [theEvent keyCode]];
}

// Capture the mouse when it's clicked in the window
- (void) mouseDown:(NSEvent *)theEvent {
        CGAssociateMouseAndMouseCursorPosition(0);  // dissociate the mouse movement from the screen
}

- (void) mouseMoved:(NSEvent *)theEvent {
    NSPoint locationInWindow = [theEvent locationInWindow];
    
//    NSLog(@"Mouse Moved. Location in window: (%f, %f)\n",
//          locationInWindow.x, locationInWindow.y);
    
//    NSLog(@"Mouse deltas: (%f, %f)\n", [theEvent deltaX], [theEvent deltaY]);
    
    // Set player movement and rotation.  The deltas can be negative, and the player movement
    // functions don't mind, and so this works.
    [player moveBackwardDistance: [theEvent deltaY] / 100];
    [player rotateRightDegrees: [theEvent deltaX] / 5];
        
      
    /*
    // Move the mouse pointer back to the center of the view
    // if it moves outside of the window bounds
    // TODO: Make this check for focus
    NSRect frame = [[self window] frame];
    if (locationInWindow.x < 0 || locationInWindow.x > frame.size.width ||
        locationInWindow.y < 0 || locationInWindow.y > frame.size.height) {
                
        // Find the center of my window in screen coordinates
        NSPoint centerOfWindowWC;   // The center of my window in window coordinates
        centerOfWindowWC.x = frame.size.width / 2;
        centerOfWindowWC.y = frame.size.height / 2;

        // TODO: move this to a move or resize event
        centerPoint = [[self window] convertBaseToScreen: centerOfWindowWC];

        NSScreen *mainScreen = [[NSScreen mainScreen] retain];
        NSRect screenFrame = [mainScreen frame];
        [mainScreen release];

        centerPoint.y = screenFrame.size.height - centerPoint.y;
        
        NSLog(@"centerPoint in screen coordinates: (%f, %f)\n", centerPoint.x, centerPoint.y);

        // CGDisplayMoveCursorToPoint(CGMainDisplayID(), centerPoint);
        CGWarpMouseCursorPosition(NSPointToCGPoint(centerPoint));
    }
    */    
}

- (void) dealloc
{
    // Release the display link
    CVDisplayLinkRelease(displayLink);
	
    [player release];
    [keyState release];
    
    // [blenderObject release];
    
    [super dealloc];
}
@end
