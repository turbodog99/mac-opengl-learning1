//
//  KeyboardState.h
//  OpenGL1
//
//  Created by Mark Herman, II on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/* This holds whether keyboard keys are down.  It is indexed by key code.
 * The only place that I know of that key codes are available is
 * Carbon/HIToolbox/Events.h
 */

#import <Foundation/Foundation.h>

@interface KeyboardState : NSObject {
@private
    // This should be enough to hold all of the key codes
    BOOL keyDown[65536];
}

// The following are properties that return whether the given key
// is up or down.
- (void) setKeyDown: (short) keycode;
- (void) setKeyUp: (short) keycode;
- (BOOL) keyDown: (short) keycode;
- (BOOL) keyUp: (short) keycode;

@end
