//
//  QuadModel.m
//  OpenGL1
//
//  Created by Mark Herman, II on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuadModel.h"

#import <stdio.h>
#import <stdlib.h>

@implementation QuadModel

- (id)init
{
    self = [super init];
    if (self) {
        quads = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) addQuad:(Quad *)newQuad
{
    [quads addObject:newQuad];
}

// Loads quads from a Blender RAW file
- (void) loadQuadsFromRawFile:(char *)filename
{
    [quads removeAllObjects];
    
    // Now open the text file and add a new quad for each line
    FILE* file;
    
    file = fopen(filename, "r");
    
    if (file == NULL) {
        NSLog(@"Failed to open file: %s\n", filename);
        return;
    }

    float inFloats[12]; // Will temporarily hold quad vertices
    
    while (!feof(file)) {
        fscanf(file, "%f %f %f %f %f %f %f %f %f %f %f %f \n", &inFloats[0], &inFloats[1], &inFloats[2], &inFloats[3],
               &inFloats[4], &inFloats[5], &inFloats[6], &inFloats[7], &inFloats[8], &inFloats[9], &inFloats[10],
               &inFloats[11]);
//        NSLog(@"Read floats: %f %f %f %f %f %f %f %f %f %f %f %f\n",  inFloats[0], inFloats[1], inFloats[2], inFloats[3],
//              inFloats[4], inFloats[5], inFloats[6], inFloats[7], inFloats[8], inFloats[9], inFloats[10],
//              inFloats[11]);
        Quad* newQuad = [[Quad alloc] init];
        [newQuad setVertices:inFloats];
        [quads addObject: newQuad];
        [newQuad release];
    }
}

- (void) draw
{
    [quads makeObjectsPerformSelector:@selector(draw)];
}

- (void) dealloc
{
    [quads release];
    [super dealloc];
}

@synthesize quads;

@end
