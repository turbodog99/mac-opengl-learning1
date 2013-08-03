//
//  Player.m
//  OpenGL1
//
//  Created by Mark Herman, II on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player

- (id)init
{
    self = [super init];
    if (self) {
        // Set some reasonable default values
        xpos = 0;
        ypos = 0;
        zpos = 0;
        yrot = 0;
        
        // Set this constant.
        piover180 = M_PI / 180.0;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@synthesize xpos, ypos, zpos, yrot;

// Moves the player forward the given distance.
- (void) moveForwardDistance : (float) distance {
    xpos -= (float)sin(yrot*piover180) * distance;			// Move On The X-Plane Based On Player Direction
	zpos -= (float)cos(yrot*piover180) * distance;			// Move On The Z-Plane Based On Player Direction
    
//    NSLog(@"Moved player to position (x,z): (%f, %f)\n", xpos, zpos);
}

// Moves the player backward the given distance.
- (void) moveBackwardDistance : (float) distance {
    xpos += (float)sin(yrot*piover180) * distance;			// Move On The X-Plane Based On Player Direction
	zpos += (float)cos(yrot*piover180) * distance;			// Move On The Z-Plane Based On Player Direction
    
//    NSLog(@"Moved player to position (x,z): (%f, %f)\n", xpos, zpos);
}

- (void) rotateLeftDegrees: (float) degrees {
    yrot += degrees;
}

- (void) rotateRightDegrees: (float) degrees {
    yrot -= degrees;
}

@end
