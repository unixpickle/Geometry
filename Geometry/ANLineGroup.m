//
//  ANLineGroup.m
//  Geometry
//
//  Created by Alex Nichol on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANLineGroup.h"

@implementation ANLineGroup

- (id)initWithCapacity:(NSUInteger)capacity {
    if ((self = [super init])) {
        vertexAlloc = capacity;
        vertices = (CGPoint *)malloc(sizeof(CGPoint) * capacity);
    }
    return self;
}

#pragma mark Mutation

- (void)setVertex:(CGPoint)aPoint atIndex:(NSUInteger)index {
    aPoint.x = round(aPoint.x);
    aPoint.y = round(aPoint.y);
    vertices[index] = aPoint;
}

- (void)addVertex:(CGPoint)aPoint {
    if (vertexCount + 1 == vertexAlloc) {
        vertexAlloc += kANLineGroupBuffer;
        vertices = (CGPoint *)realloc(vertices, sizeof(CGPoint) * vertexAlloc);
    }
    aPoint.x = round(aPoint.x);
    aPoint.y = round(aPoint.y);
    vertices[vertexCount++] = aPoint;
}

- (CGPoint)popVertex {
    if (vertexCount == 0) return CGPointZero;
    CGPoint point = vertices[--vertexCount];
    return point;
}

- (void)clear {
    vertexCount = 0;
}

#pragma mark Accessing

- (NSUInteger)numberOfVertices {
    return vertexCount;
}

- (CGPoint)vertexAtIndex:(NSUInteger)index {
    return vertices[index];
}

- (BOOL)isClosed {
    if (vertexCount < 2) return NO;
    return CGPointEqualToPoint(vertices[0], vertices[vertexCount - 1]);
}

@end
