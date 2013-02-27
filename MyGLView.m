//
//  MyGLView.m
//  OpenGL1
//
//  Created by Mark Herman, II on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

// This seems to be the best place to find keyboard codes
#import "HIToolbox/Events.h"

#import "MyGLView.h"

@implementation MyGLView
-(void)awakeFromNib
{
    readyToDraw = NO;
    angle = 0;
    piover180 = M_PI / 180.0;
    player = [[Player alloc] init];
    keyState = [[KeyboardState alloc] init];
    [[self window] setAcceptsMouseMovedEvents: YES];
    
    centerPoint.x = 200;
    centerPoint.y = 200;
    
    // Load my model object from Blender
    blenderObject = [[QuadModel alloc] init];
    [blenderObject loadQuadsFromRawFile:"/Users/markherman/blender/learning1.raw"];
}

void DrawTriangle (void)
{
	glBegin(GL_TRIANGLES);
	
	glColor3f(1.0f, 0.0f, 0.0f);
	glVertex3f(-1.0f, -0.5f, 0.0f);
	
	glColor3f(0.0f, 1.0f, 0.0f);
	glVertex3f( 1.0f, -0.5f, 0.0f);
	
	glColor3f(0.0f, 0.0f, 1.0f);
	glVertex3f( 0.0f,  0.5f, 0.0f);
	
	glEnd();
}

void DrawPyramid (void)
{
    glBegin(GL_TRIANGLES);
    
    // Front face
    glColor3f(1.0f, 0.0f, 0.0f);        // Red
    glVertex3f(0.0f, 1.0f, 0.0f);       // Top of Triangle (Front)
    // glColor3f(0.0f, 1.0f, 0.0f);        // Green
    glVertex3f(-1.0f, -1.0f, 1.0f);     // Left of Triangle (Front)
    //    glColor3f(0.0f, 0.0f, 1.0f);        // Blue
    glVertex3f(1.0f, -1.0f, 1.0f);      // Right of Triangle (Front)
    
    // Right face
    // glColor3f(1.0f, 0.0f, 0.0f);        // Red
    glColor3f(0.0f, 0.0f, 1.0f);        // Blue

    glVertex3f(0.0f, 1.0f, 0.0f);       // Top of Triangle (Right)
//    glColor3f(0.0f, 0.0f, 1.0f);        // Blue
    glVertex3f(1.0f, -1.0f, 1.0f);      // Left of Triangle (Right)
//    glColor3f(0.0f, 1.0f, 0.0f);        // Green
    glVertex3f(1.0f, -1.0f, -1.0f);     // Right of Triangle (Right)
    
    // Back face
    glColor3f(0.0f, 1.0f, 0.0f);        // Green
//    glColor3f(1.0f, 0.0f, 0.0f);        // Red
    glVertex3f(0.0f, 1.0f, 0.0f);       // Top of Triangle (Back)
//    glColor3f(0.0f, 1.0f, 0.0f);        // Green
    glVertex3f(1.0f, -1.0f, -1.0f);     // Left of Triangle (Back)
//    glColor3f(0.0f, 0.0f, 1.0f);        // Blue
    glVertex3f(-1.0f, -1.0f, -1.0f);     // Right of Triangle (Back)
    
    // Left face
    glColor3f(1.0f, 1.0f, 0.0f);
//    glColor3f(1.0f, 0.0f, 0.0f);        // Red
    glVertex3f(0.0f, 1.0f, 0.0f);       // Top of Triangle (Left)
//    glColor3f(0.0f, 0.0f, 1.0f);        // Blue
    glVertex3f(-1.0f, -1.0f, -1.0f);    // Left of Triangle (Left)
//    glColor3f(0.0f, 1.0f, 0.0f);        // Green
    glVertex3f(-1.0f, -1.0f, 1.0f);     // Done drawing the pyramid

    glEnd();
    
    glBegin(GL_QUADS);
    
    // Bottom face
    glColor3f(1.0f, 1.0f, 1.0f);
    glVertex3f(-1.0f, -1.0f, 1.0f);
    glVertex3f(1.0f, -1.0f, 1.0f);
    glVertex3f(1.0f, -1.0f, -1.0f);
    glVertex3f(-1.0f, -1.0f, -1.0f);
    
    glEnd();
}

- (void)prepareOpenGL
{
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
	
    glEnable (GL_DEPTH_TEST);
    
    // Activate the display link
    CVDisplayLinkStart(displayLink);
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{    
    CVReturn result = (CVReturn) [(MyGLView*)displayLinkContext getFrameForTime:outputTime];
    return result;
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
    
	NSOpenGLContext *currentContext;
	GLfloat x_m, y_m, z_m, u_m, v_m;				// Floating Point For Temp X, Y, Z, U And V Vertices
	GLfloat xtrans = -[player xpos];						// Used For Player Translation On The X Axis
	GLfloat ztrans = -[player zpos];						// Used For Player Translation On The Z Axis
	GLfloat ytrans = -walkbias-0.25f;				// Used For Bouncing Motion Up And Down
	GLfloat sceneroty = 360.0f - [player yrot];				// 360 Degree Angle For Player Direction
    
	
	currentContext = [self openGLContext];
	[currentContext makeCurrentContext];
	
	CGLLockContext([currentContext CGLContextObj]);
	
	if (!readyToDraw) {
		// Doing first run init stuff
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
	
		CGRect bounds = [self bounds];
	
		gluPerspective(90.0f, bounds.size.width / bounds.size.height, 0.2f, 255.0f);
	
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		
		glViewport(0, 0, bounds.size.width, bounds.size.height);
		
		readyToDraw = YES;
	}
	
	
    glClearColor(0, 0, 0, 0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
    glLoadIdentity();
    
	glColor3f(1.0f, 0.85f, 0.35f);
	/*
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(  0.0,  0.6, 0.0);
        glVertex3f( -0.2, -0.3, 0.0);
        glVertex3f(  0.2, -0.3 ,0.0);
    }
    glEnd();
	*/

	glRotatef(sceneroty,0,1.0f,0);					// Rotate Depending On Direction Player Is Facing
	glTranslatef(xtrans, ytrans, ztrans);				// Translate The Scene Based On Player Position	
	
    
//	glRotatef(angle, angle, angle, 1.0f);
	

	glTranslatef(0.0f, 0.0f, -4.0f);
	glRotatef(angle, 0.0f, 0.0f, 1.0f);
	
	// DrawTriangle();
	
    // Scale by the slider's scale factor
    float scaleFactor = [scaleSlider floatValue];
    
    glScalef(scaleFactor, scaleFactor, scaleFactor);
    DrawPyramid();
    
    [blenderObject draw];
    
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
    
	[currentContext flushBuffer];
	
	CGLUnlockContext([currentContext CGLContextObj]);
	
    return kCVReturnSuccess;
}

-(BOOL)acceptsFirstResponder { return YES; }
-(BOOL)becomeFirstResponder  { return YES; }
-(BOOL)resignFirstResponder  { return YES; }

/* The following capture scroll (arrow key) events.
 
-(IBAction)moveUp:(id)sender
{
	[player moveForwardDistance:1.0f];
}

-(IBAction)moveDown:(id)sender
{
	[player moveBackwardDistance:1.0f];
}

-(IBAction)moveLeft:(id)sender
{
    [player rotateLeftDegrees:1.5];
}

-(IBAction)moveRight:(id)sender
{
    [player rotateRightDegrees:1.5];
}
*/

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
    
    NSLog(@"Mouse Moved. Location in window: (%f, %f)\n",
          locationInWindow.x, locationInWindow.y);
    
    NSLog(@"Mouse deltas: (%f, %f)\n", [theEvent deltaX], [theEvent deltaY]);
    
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

- (void)dealloc
{
    // Release the display link
    CVDisplayLinkRelease(displayLink);
	
    [player release];
    [keyState release];
    
    [blenderObject release];
    
    [super dealloc];
}
@end
