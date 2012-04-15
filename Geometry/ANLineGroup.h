//
//  ANLineGroup.h
//  Geometry
//
//  Created by Alex Nichol on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kANLineGroupBuffer 32

@interface ANLineGroup : NSObject {
    CGPoint * vertices;
    NSUInteger vertexCount;
    NSUInteger vertexAlloc;
}

- (id)initWithCapacity:(NSUInteger)capacity;

- (void)setVertex:(CGPoint)aPoint atIndex:(NSUInteger)index;
- (void)addVertex:(CGPoint)aPoint;
- (CGPoint)popVertex;
- (void)clear;

- (NSUInteger)numberOfVertices;
- (CGPoint)vertexAtIndex:(NSUInteger)index;
- (BOOL)isClosed;

@end
