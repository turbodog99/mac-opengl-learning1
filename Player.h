//
//  Player.h
//  OpenGL1
//
//  Created by Mark Herman, II on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Player : NSObject {
@private
    // X position, Y position, and Y rotation of the player.
    float xpos, ypos, zpos, yrot;
    float piover180;
}

@property (readwrite, assign) float xpos, ypos, zpos, yrot;

// Moves the player forward the given distance.
- (void) moveForwardDistance : (float) distance;

// Moves the player backward the given distance.
- (void) moveBackwardDistance : (float) distance;

// Rotates the player to the left the given number of degrees.
- (void) rotateLeftDegrees : (float) degrees;

// Rotates the player to the right the given number of degrees.
- (void) rotateRightDegrees : (float) degrees;

@end
