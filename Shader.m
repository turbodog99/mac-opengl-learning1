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
        _shaderFileExtensions = [NSMutableDictionary dictionaryWithCapacity: 5];
        
        [self setupDefaultFileExtensions];

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
    
    NSURL *shaderURL = [mainBundle URLForResource: @"SimpleShader"
                                    withExtension: [self fileExtension]
                                     subdirectory: @"Shaders"];

    if (shaderURL == nil) {
        NSLog(@"Could not find shader URL");
//        NSLog(@"Attempted to use file extension %@", [self fileExtension]);
    } else {
        NSLog(@"Shader URL: %@", shaderURL);
    }
    
    [self loadFromURL: shaderURL];
}

- (void) loadFromURL: (NSURL *) url
{
    [self setShaderText: [NSString stringWithContentsOfURL: url
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

- (NSString *) stringForShaderType: (GLenum) shaderType
{
    switch (shaderType) {
        case GL_VERTEX_SHADER:
            return @"vertex";
        case GL_FRAGMENT_SHADER:
            return @"fragment";
        default:
            return nil;
    }
}

// Returns a friendly name for the shader type, for example, "vertex" or "fragment".
- (NSString *) shaderTypeString
{
    return [self stringForShaderType: [self type]];
}

/* Resource bundles care about file extensions.  This sets the file extension of
 * the current shader type.  Must be called before loading.
 *
 * There are reasonable defaults.
 *
 * Note: if you change shader types, you'll need to call this again.
 */
- (void) setFileExtension: (NSString *) extension
{
    [[ self shaderFileExtensions] setValue: extension
                                    forKey: [self stringForShaderType: [self type]]];
}

- (NSString *) fileExtension
{
    return [[self shaderFileExtensions] valueForKey: [self shaderTypeString]];
}

- (void) setupDefaultFileExtensions
{
    [[self shaderFileExtensions] setValue: @"vs"
                                   forKey: [self stringForShaderType: GL_VERTEX_SHADER]];
    [[self shaderFileExtensions] setValue: @"fs"
                                   forKey: [self stringForShaderType: GL_FRAGMENT_SHADER]];
}

@synthesize type = _type;
@synthesize glShader = _glShader;
@synthesize shaderText = _shaderText;
@synthesize compileStatus = _compileStatus;
@synthesize shaderFileExtensions = _shaderFileExtensions;

@end
