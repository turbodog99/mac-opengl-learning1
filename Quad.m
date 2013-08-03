//
//  Quad.m
//  OpenGL1
//
//  Created by Mark Herman, II on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Quad.h"
#import <OpenGL/gl3.h>

@implementation Quad

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) setVertices: (float*) newVertices {
    // copy the passed array into my vertex array
    for (int x = 0; x < 12; x++) {
        ((float*) vertices)[x] = newVertices[x];
    }
}

- (float*) vertices {
    return (float*) vertices;
}

- (void) draw
{
    glBegin(GL_QUADS);
	
	glVertex3f(vertices[0][0], vertices[0][1], vertices[0][2]);
	glVertex3f(vertices[1][0], vertices[1][1], vertices[1][2]);
	glVertex3f(vertices[2][0], vertices[2][1], vertices[2][2]);
	glVertex3f(vertices[3][0], vertices[3][1], vertices[3][2]);
    	
	glEnd();
}

@end
