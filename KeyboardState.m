//
//  KeyboardState.m
//  OpenGL1
//
//  Created by Mark Herman, II on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyboardState.h"


@implementation KeyboardState

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) setKeyDown: (short) keycode {
    keyDown[keycode] = YES;
}

- (void) setKeyUp: (short) keycode {
    keyDown[keycode] = NO;
}

- (BOOL) keyDown: (short) keycode {
    return keyDown[keycode];
}

- (BOOL) keyUp: (short) keycode {
    return !keyDown[keycode];
}

@end
