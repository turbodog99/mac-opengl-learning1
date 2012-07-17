//
//  Quad.h
//  OpenGL1
//
//  Created by Mark Herman, II on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quad : NSObject {

// This will contain 4 sets of x, y, and z coordinates
float vertices[4][3];

}

- (void) setVertices: (float*) vertices;
- (float*) vertices;

// Draws this quad
- (void) draw;

@end
