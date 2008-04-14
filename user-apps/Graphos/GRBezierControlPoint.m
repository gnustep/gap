/*
 Project: Graphos
 GRBezierControlPoint.h

 Copyright (C) 2000-2008 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

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


#import "GRBezierControlPoint.h"
#import "GRBezierPathEditor.h"
#import "GRFunctions.h"

@implementation GRBezierControlPoint

- (id)initAtPoint:(NSPoint)aPoint
        forPath:(GRBezierPath *)aPath
       zoomFactor:(float)zf
{
    self = [super init];
    if(self)
    {
        path = aPath;
        zmFactor = zf;
        bzHandle.center = aPoint;
        bzHandle.centerRect = NSMakeRect(aPoint.x-3, aPoint.y-3, 6, 6);
        [self calculateBezierHandles: aPoint];
        isSelect = NO;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)calculateBezierHandles:(NSPoint)draggedHandlePos
{
    double distx, disty;

    bzHandle.firstHandle = draggedHandlePos;
    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);

    distx = grmax(bzHandle.firstHandle.x, bzHandle.center.x) - grmin(bzHandle.firstHandle.x, bzHandle.center.x);
    if(bzHandle.firstHandle.x > bzHandle.center.x)
        bzHandle.secondHandle.x = bzHandle.center.x - distx;
    else
        bzHandle.secondHandle.x = bzHandle.center.x + distx;

    disty = grmax(bzHandle.firstHandle.y, bzHandle.center.y) - grmin(bzHandle.firstHandle.y, bzHandle.center.y);
    if(bzHandle.firstHandle.y > bzHandle.center.y)
        bzHandle.secondHandle.y = bzHandle.center.y - disty;
    else
        bzHandle.secondHandle.y = bzHandle.center.y + disty;

    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);

    if(distx || disty)
        isActiveHandle = YES;
}

- (void)moveToPoint:(NSPoint)p
{
    double xdiff, ydiff;

    xdiff = p.x - bzHandle.center.x;
    ydiff = p.y - bzHandle.center.y;
    bzHandle.center.x += xdiff;
    bzHandle.center.y += ydiff;
    bzHandle.centerRect = NSMakeRect(bzHandle.center.x-3, bzHandle.center.y-3, 6, 6);
    bzHandle.firstHandle.x += xdiff;
    bzHandle.firstHandle.y += ydiff;
    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
    bzHandle.secondHandle.x += xdiff;
    bzHandle.secondHandle.y += ydiff;
    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);
}

- (void)moveBezierHandleToPosition:(NSPoint)newp oldPosition:(NSPoint)oldp
{
    GRBezierControlPoint *mtopoint, *ponpoint = nil;
    double distx, disty;

    mtopoint = [path firstPoint];
    ponpoint = [path pointOnPoint: self];
    if(ponpoint && [(GRPathEditor *)[path editor] isdone] && (self == mtopoint))
        [ponpoint moveBezierHandleToPosition: newp oldPosition: oldp];

    if(pointInRect(bzHandle.firstHandleRect, oldp)) {
        bzHandle.firstHandle = newp;
        distx = grmax(bzHandle.firstHandle.x, bzHandle.center.x) - grmin(bzHandle.firstHandle.x, bzHandle.center.x);
        disty = grmax(bzHandle.firstHandle.y, bzHandle.center.y) - grmin(bzHandle.firstHandle.y, bzHandle.center.y);
        if(bzHandle.firstHandle.x > bzHandle.center.x)
            bzHandle.secondHandle.x = bzHandle.center.x - distx;
        else
            bzHandle.secondHandle.x = bzHandle.center.x + distx;
        if(bzHandle.firstHandle.y > bzHandle.center.y)
            bzHandle.secondHandle.y = bzHandle.center.y - disty;
        else
            bzHandle.secondHandle.y = bzHandle.center.y + disty;
    }

    if(pointInRect(bzHandle.secondHandleRect, oldp))
    {
        bzHandle.secondHandle = newp;
        distx = grmax(bzHandle.secondHandle.x, bzHandle.center.x) - grmin(bzHandle.secondHandle.x, bzHandle.center.x);
        disty = grmax(bzHandle.secondHandle.y, bzHandle.center.y) - grmin(bzHandle.secondHandle.y, bzHandle.center.y);
        if(bzHandle.secondHandle.x > bzHandle.center.x)
            bzHandle.firstHandle.x = bzHandle.center.x - distx;
        else
            bzHandle.firstHandle.x = bzHandle.center.x + distx;
        if(bzHandle.secondHandle.y > bzHandle.center.y)
            bzHandle.firstHandle.y = bzHandle.center.y - disty;
        else
            bzHandle.firstHandle.y = bzHandle.center.y + disty;
    }

    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);
}

- (void)setZoomFactor:(float)f
{
    bzHandle.center.x = bzHandle.center.x / zmFactor * f;
    bzHandle.center.y = bzHandle.center.y / zmFactor * f;
    bzHandle.centerRect = NSMakeRect(bzHandle.center.x-3, bzHandle.center.y-3, 6, 6);
    bzHandle.firstHandle.x = bzHandle.firstHandle.x / zmFactor * f;
    bzHandle.firstHandle.y = bzHandle.firstHandle.y / zmFactor * f;
    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
    bzHandle.secondHandle.x = bzHandle.secondHandle.x / zmFactor * f;
    bzHandle.secondHandle.y = bzHandle.secondHandle.y / zmFactor * f;
    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);

    zmFactor = f;
}

- (GRBezierHandle)bzHandle
{
    return bzHandle;
}

- (NSPoint)center
{
    return bzHandle.center;
}

- (NSRect)centerRect;
{
    return bzHandle.centerRect;
}

- (void)select
{
    double distx, disty;

    isSelect = YES;
    [(GRBezierPathEditor *)[path editor] unselectOtherControls: self];
    distx = grmax(bzHandle.firstHandle.x, bzHandle.center.x) - grmin(bzHandle.firstHandle.x, bzHandle.center.x);
    disty = grmax(bzHandle.firstHandle.y, bzHandle.center.y) - grmin(bzHandle.firstHandle.y, bzHandle.center.y);
    if(distx || disty)
        isActiveHandle = YES;
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
