//
//  Shader.m
//  OpenGL1
//
//  Created by Mark Herman, II on 8/2/13.
//
//

#import "Shader.h"

@implementation Shader

- (id) init
{
    return nil; // Can't init without a type
}

- (id) initWithType: (GLenum) shaderType
{
    if (self = [super init]) {
        _type = shaderType;
        return self;
    } else {
        return nil;
    }
}

- (void) loadFromResourceWithName: (NSString *) name
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    if (mainBundle == nil)
        NSLog(@"Failed to get reference to main bundle");
    
    NSString *shaderFileExtension;
    
    switch ([self type]) {
        case GL_VERTEX_SHADER:
            shaderFileExtension = @"vs";
            break;
        case GL_FRAGMENT_SHADER:
            shaderFileExtension = @"fs";
            break;
    }
    
    NSString *shaderPath = [mainBundle pathForResource: @"SimpleShader"
                                                ofType: shaderFileExtension
                                           inDirectory: @"Shaders"];
    
    NSLog(@"Shader path: %@", shaderPath);

    [self loadFromFileWithName: shaderPath];
}

- (void) loadFromFileWithName: (NSString *) filename
{
    [self setShaderText: [NSString stringWithContentsOfFile: filename
                                                   encoding: NSUTF8StringEncoding
                                                      error: nil]];
    
    NSLog(@"Shader text: %@", [self shaderText]);
    
    const char *shaderTextPtr = [[self shaderText] UTF8String];

    [self createShader];
    
    glShaderSource([self glShader], 1, &shaderTextPtr, NULL);
    glCompileShader([self glShader]);
    
    glGetShaderiv([self glShader], GL_COMPILE_STATUS, &_compileStatus);
    
    if ([self compileStatus] == GL_TRUE) {
        NSLog(@"Shader compilation succeeded");
    } else {
        NSLog(@"Shader compilation failed.");
        char log[8192];
        GLsizei logLength = 0;
        glGetShaderInfoLog([self glShader], 8192, &logLength, log);
        
        if (strlen(log) > 0) {
            fprintf(stderr, "Shader info log: %s\n", log);
            fprintf(stderr, "Log length: %d\n", logLength);
        }
    }
}

- (void) createShader
{
    [self setGlShader: glCreateShader([self type])];

    if ([self glShader] == 0) {
        NSLog(@"Failed to create shader");
    }
}

@synthesize type = _type;
@synthesize glShader = _glShader;
@synthesize shaderText = _shaderText;
@synthesize compileStatus = _compileStatus;

@end
