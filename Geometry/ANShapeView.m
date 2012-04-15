//
//  ANShapeView.m
//  Geometry
//
//  Created by Alex Nichol on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANShapeView.h"

static CGFloat CGPointDistance (CGPoint p1, CGPoint p2);
static CGPoint CGPointMidpoint (CGPoint p1, CGPoint p2);

@interface ANShapeView (Private)

- (void)drawAngleLabels;
- (void)drawLengthLabels;
- (BOOL)putLabelAboveLine:(CGPoint *)points;

@end

@implementation ANShapeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        lineGroup = [[ANLineGroup alloc] initWithCapacity:8];
    }
    return self;
}

- (void)undoDraw:(id)sender {
    if ([lineGroup numberOfVertices] > 0) {
        [lineGroup popVertex];
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([lineGroup isClosed]) {
        [lineGroup clear];
    }
    CGPoint point = [[touches anyObject] locationInView:self];
    if ([lineGroup numberOfVertices] == 0) {
        [lineGroup addVertex:point];
    }
    [lineGroup addVertex:point];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPoint startPoint = [lineGroup vertexAtIndex:0];
    if (CGPointDistance(startPoint, point) < 10) point = startPoint;
    [lineGroup setVertex:point atIndex:([lineGroup numberOfVertices] - 1)];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1, 1, 1, 0.5);
    for (int i = 0; i < [lineGroup numberOfVertices]; i++) {
        CGPoint vertexPoint = [lineGroup vertexAtIndex:i];
        CGRect circleRect = CGRectMake(vertexPoint.x - 10, vertexPoint.y - 10, 20, 20);
        CGContextFillEllipseInRect(context, circleRect);
    }
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextSetLineWidth(context, 5);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextBeginPath(context);
    for (int i = 0; i < [lineGroup numberOfVertices]; i++) {
        CGPoint vertexPoint = [lineGroup vertexAtIndex:i];
        if (i == 0) {
            CGContextMoveToPoint(context, vertexPoint.x, vertexPoint.y);
        } else {
            CGContextAddLineToPoint(context, vertexPoint.x, vertexPoint.y);
        }
    }
    CGContextStrokePath(context);
    
    [self drawAngleLabels];
    [self drawLengthLabels];
}

- (void)drawAngleLabels {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIFont * font = [UIFont systemFontOfSize:18];
    int max = (int)[lineGroup numberOfVertices] - ([lineGroup isClosed] ? 0 : 1);
    for (int i = 1; i < max; i++) {
        CGPoint p1, p2, p3;
        if (i == [lineGroup numberOfVertices] - 1) {
            p1 = [lineGroup vertexAtIndex:1];
            p2 = [lineGroup vertexAtIndex:i];
            p3 = [lineGroup vertexAtIndex:i - 1];
        } else {
            p1 = [lineGroup vertexAtIndex:i - 1];
            p2 = [lineGroup vertexAtIndex:i];
            p3 = [lineGroup vertexAtIndex:i + 1];
        }
        
        double angle1 = atan2(p1.y - p2.y, p1.x - p2.x) * (180.0 / M_PI);
        double angle2 = atan2(p3.y - p2.y, p3.x - p2.x) * (180.0 / M_PI);
        double diff = ABS(angle1 - angle2);
        if (diff > 180) diff = 360 - diff;
        
        NSString * angleLable = [NSString stringWithFormat:@"%d", (int)round(diff)];
        CGSize size = [angleLable sizeWithFont:font];
        CGRect labelFrame = CGRectMake(p2.x - size.width, p2.y - size.height / 2, size.width, size.height);
        
        CGContextSetRGBFillColor(context, 1, 1, 1, 0.75);
        CGFloat minX = CGRectGetMinX(labelFrame), maxX = CGRectGetMaxX(labelFrame);
        CGFloat minY = CGRectGetMinY(labelFrame), maxY = CGRectGetMaxY(labelFrame);
        CGFloat radius = 5;
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, minX + radius, minY);
        CGContextAddArcToPoint(context, minX, minY, minX, maxY - radius, radius);
        CGContextAddArcToPoint(context, minX, maxY, maxX - radius, maxY, radius);
        CGContextAddArcToPoint(context, maxX, maxY, maxX, minY + radius, radius);
        CGContextAddArcToPoint(context, maxX, minY, minX + radius, minY, radius);
        CGContextClosePath(context);
        CGContextFillPath(context);
        
        CGContextSetRGBFillColor(context, 0, 0, 0, 1);
        [angleLable drawInRect:labelFrame withFont:font];
    }
}

- (void)drawLengthLabels {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIFont * font = [UIFont systemFontOfSize:18];
    for (int i = 0; i + 1 < [lineGroup numberOfVertices]; i++) {
        CGPoint p1 = [lineGroup vertexAtIndex:i];
        CGPoint p2 = [lineGroup vertexAtIndex:i + 1];
        CGFloat length = CGPointDistance(p1, p2);
        CGPoint midpoint = CGPointMidpoint(p1, p2);
        
        NSString * measureLable = [NSString stringWithFormat:@"%.1f", length];
        CGSize size = [measureLable sizeWithFont:font];
        CGRect labelFrame = CGRectMake(midpoint.x - size.width / 2.0, 
                                       midpoint.y - size.height / 2.0,
                                       size.width, size.height);

        CGContextSetRGBFillColor(context, 1, 1, 1, 0.75);
        CGFloat minX = CGRectGetMinX(labelFrame), maxX = CGRectGetMaxX(labelFrame);
        CGFloat minY = CGRectGetMinY(labelFrame), maxY = CGRectGetMaxY(labelFrame);
        CGFloat radius = 5;
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, minX + radius, minY);
        CGContextAddArcToPoint(context, minX, minY, minX, maxY - radius, radius);
        CGContextAddArcToPoint(context, minX, maxY, maxX - radius, maxY, radius);
        CGContextAddArcToPoint(context, maxX, maxY, maxX, minY + radius, radius);
        CGContextAddArcToPoint(context, maxX, minY, minX + radius, minY, radius);
        CGContextClosePath(context);
        CGContextFillPath(context);
        
        CGContextSetRGBFillColor(context, 0, 0, 0, 1);
        [measureLable drawInRect:labelFrame withFont:font];
    }
}

- (BOOL)putLabelAboveLine:(CGPoint *)points {
    CGPoint p1 = points[0];
    CGPoint p2 = points[1];
    NSUInteger above = 0;
    NSUInteger below = 0;
    if (p1.x == p2.x) {
        for (int i = 0; i < [lineGroup numberOfVertices]; i++) {
            CGPoint point = [lineGroup vertexAtIndex:i];
            if (point.x < p1.x) above++;
            else if (point.x > p1.x) below++;
        }
    } else {
        CGFloat slope = (p2.y - p1.y) / (p2.x - p1.x);
        CGFloat yIntercept = p1.y - (slope * (p1.x));
        for (int i = 0; i < [lineGroup numberOfVertices]; i++) {
            CGPoint point = [lineGroup vertexAtIndex:i];
            CGFloat genY = slope * point.x + yIntercept;
            if (point.y < genY) {
                above++;
            } else if (point.y > genY) {
                below++;
            }
        }
    }
    return above > below;
}

@end

static CGFloat CGPointDistance (CGPoint p1, CGPoint p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
}

static CGPoint CGPointMidpoint (CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}
