//
//  GRPathObject.m
//  Graphos
//
//  Created by Riccardo Mottola on Fri Mar 14 2008.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import "GRPathObject.h"


@implementation GRPathObject

- (void)setFilled:(BOOL)value
{
    filled = value;
}

- (BOOL)isFilled
{
    return filled;
}

- (void)setStroked:(BOOL)value
{
    stroked = value;
}

- (BOOL)isStroked
{
    return stroked;
}
- (void)setCurrentPoint:(GRObjectControlPoint *)aPoint
{
    currentPoint = aPoint;
}

- (GRObjectControlPoint *)currentPoint
{
    return currentPoint;
}

- (void)remakePath
{
}

@end
