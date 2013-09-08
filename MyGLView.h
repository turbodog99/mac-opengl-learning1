//
//  MyGLView.h
//  OpenGL1
//
//  Created by Mark Herman, II on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGL/gl3.h>

#include <math.h>

#import "Player.h"
#import "KeyboardState.h"
#import "QuadModel.h"

// GL Objects
GLuint programPipeline;

GLfloat projMatrix[16];
GLfloat viewMatrix[16];

@interface MyGLView : NSOpenGLView
{
    CVDisplayLinkRef displayLink; //display link for managing rendering thread
	GLfloat angle;
	BOOL readyToDraw;
	GLfloat yrot, xpos, zpos, heading;
	GLfloat walkbiasangle, walkbias;
	GLfloat piover180;
    IBOutlet NSSlider *scaleSlider;
    Player *player;
    KeyboardState *keyState;
    NSPoint centerPoint;    // A point around which I'll be tracking mouse events
    QuadModel* blenderObject;
}

static CVReturn MyDisplayLinkCallback (
								CVDisplayLinkRef displayLink,
								const CVTimeStamp *inNow,
								const CVTimeStamp *inOutputTime,
								CVOptionFlags flagsIn,
								CVOptionFlags *flagsOut,
								void *displayLinkContext
								);
@end
