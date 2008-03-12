/*
 Project: Graphos
 GRObjectControlPoint.m

 Copyright (C) 2007-2008 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2007-11-18

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "GRObjectControlPoint.h"


@implementation GRObjectControlPoint

- (id)initAtPoint:(NSPoint)aPoint
{
    self = [super init];
    if(self)
    {
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
    innerRect = NSMakeRect(p.x-2, p.y-2, 4, 4);
}

- (NSPoint)center
{
    return center;
}

- (NSRect)centerRect;
{
    return centerRect;
}

- (NSRect)innerRect;
{
    return innerRect;
}

- (void)select
{
    isSelect = YES;
}

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
