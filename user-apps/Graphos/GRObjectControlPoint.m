//
//  GRObjectControlPoint.m
//  Graphos
//
//  Created by Riccardo Mottola on Tue Sep 18 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GRObjectControlPoint.h"


@implementation GRObjectControlPoint

- (id)initAtPoint:(NSPoint)aPoint
{
    self = [super init];
    if(self) {
        center = aPoint;
        centerRect = NSMakeRect(aPoint.x-3, aPoint.y-3, 6, 6);
        isSelect = NO;
    }
    return self;
}

- (void)moveToPoint:(NSPoint)p
{
    center.x = p.x;
    center.y = p.y;
    centerRect = NSMakeRect(center.x-3, center.y-3, 6, 6);
}

- (NSPoint)center
{
    return center;
}

- (NSRect)centerRect;
{
    return centerRect;
}

- (void)select
{
    isSelect = YES;}

- (void)unselect
{
    isSelect = NO;
}

- (BOOL)isSelect
{
    return isSelect;
}

- (BOOL)isActiveHandle
{
    return isActiveHandle;
}


@end
