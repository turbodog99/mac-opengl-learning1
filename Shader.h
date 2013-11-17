//
//  Shader.h
//  OpenGL1
//
//  Created by Mark Herman, II on 8/2/13.
//
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>

@interface Shader : NSObject
- (id) initWithType: (GLenum) shaderType;
- (void) loadFromResourceWithName: (NSString *) name;
- (void) loadFromURL: (NSURL *) url;
- (NSString *) stringForShaderType: (GLenum) shaderType;
- (NSString *) fileExtension;
- (NSString *) shaderTypeString;
- (void) setFileExtension: (NSString *) extension;


@property GLenum type;
@property GLuint glShader;
@property GLint compileStatus;
@property (nonatomic, retain) NSString *shaderText;
@property (nonatomic, retain) NSDictionary *shaderFileExtensions;
@end