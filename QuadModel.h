//
//  QuadModel.h
//  OpenGL1
//
//  Created by Mark Herman, II on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Quad.h"

@interface QuadModel : NSObject {
    NSMutableArray* quads;
}

@property(retain) NSMutableArray* quads;

- (void) addQuad: (Quad*) newQuad;
- (void) loadQuadsFromRawFile: (char*) filename;
- (void) draw;

@end
