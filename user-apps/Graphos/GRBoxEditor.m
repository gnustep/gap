/*
 Project: Graphos
 GRBoxEditor.m

 Copyright (C) 2007-2008 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2007-09-18

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

#import "GRBoxEditor.h"
#import "GRDocView.h"

@implementation GRBoxEditor

- (id)initEditor:(GRBox *)anObject
{
    self = [super init];
    if(self != nil)
    {
        object = anObject;
        groupSelected = NO;
        editSelected = NO;
        isdone = NO;
        isvalid = NO;
    }
    return self;
}

- (BOOL)isdone
{
    return isdone;
}

- (void)setIsDone:(BOOL)status
{
    isdone = status;

}
- (void)select
{
    [self selectAsGroup];
}

- (void)selectAsGroup
{
    if([object locked])
        return;

    if(!groupSelected)
    {
        groupSelected = YES;
        editSelected = NO;
        isvalid = NO;

        [[object view] unselectOtherObjects: object];
    }
}

- (void)selectForEditing
{
    if([object locked])
        return;
    editSelected = YES;
    groupSelected = NO;
    isvalid = NO;
    [[object view] unselectOtherObjects: object];
}


- (void)unselect
{
    groupSelected = NO;
    editSelected = NO;
    isvalid = YES;
    isdone = YES;
}

- (BOOL)isSelect
{
    if(editSelected || groupSelected)
        return YES;
    return NO;
}

- (BOOL)isGroupSelected
{
    return groupSelected;
}

- (BOOL)isEditSelected
{
    return editSelected;
}

- (NSPoint)moveControlAtPoint:(NSPoint)p
{
    GRObjectControlPoint *cp, *pntonpnt;
    NSEvent *event;
    NSPoint pp;
    BOOL found = NO;
    int i;

    cp = [object startControlPoint];
    if (pointInRect([cp centerRect], p))
    {
        [self selectForEditing];
        [object setCurrentPoint:cp];
        [cp select];
        found =  YES;
    }
    cp = [object endControlPoint];
    if (pointInRect([cp centerRect], p))
    {
        [self selectForEditing];
        [object setCurrentPoint:cp];
        [cp select];
        found =  YES;
    }
    
    if(!found)
        return p;

    event = [[[object view] window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    if([event type] == NSLeftMouseDragged)
    {
        [[object view] verifyModifiersOfEvent: event];
        do
        {
            pp = [event locationInWindow];
            pp = [[object view] convertPoint: pp fromView: nil];
//            if([[object view] shiftclick])
//                pp = pointApplyingCostrainerToPoint(pp, p);

/*            pntonpnt = [object pointOnPoint: [object currentPoint]];
            if(pntonpnt)
            {
                if([object currentPoint] == [object firstPoint] || pntonpnt == [object firstPoint])
                    [pntonpnt moveToPoint: pp];
            } */
            [[object currentPoint] moveToPoint: pp];
            [object remakePath];

            [[object view] setNeedsDisplay: YES];
            event = [[[object view] window] nextEventMatchingMask:
                NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            [[object view] verifyModifiersOfEvent: event];
        } while([event type] != NSLeftMouseUp);
    }

    return pp;
}

- (void)moveControlAtPoint:(NSPoint)oldp toPoint:(NSPoint)newp
{
    GRObjectControlPoint *cp, *pntonpnt;
    BOOL found = NO;
    int i;

    cp = [object startControlPoint];
    if (pointInRect([cp centerRect], oldp))
    {
        [self selectForEditing];//
        [object setCurrentPoint:cp];
        [cp select];
        found =  YES;
    }
    cp = [object endControlPoint];
    if (pointInRect([cp centerRect], oldp))
    {
        [self selectForEditing];
        [object setCurrentPoint:cp];
        [cp select];
        found =  YES;
    }
    
    if(!found)
        return;
/*
    pntonpnt = [object pointOnPoint: [object currentPoint]];
    if(pntonpnt)
    {
        if([object currentPoint] == [object firstPoint] || pntonpnt == [object firstPoint])
            [pntonpnt moveToPoint: newp];
    }*/
    [[object currentPoint] moveToPoint: newp];
//    [object remakePath];
    [[object view] setNeedsDisplay: YES];
}


- (void)draw
{
    NSBezierPath *bzp;

    if(![object visible])
        return;

    bzp = [NSBezierPath bezierPath];
    
    [bzp setLineWidth:1];

    if([self isGroupSelected])
    {
        NSRect r;

        r = [[object startControlPoint] centerRect];
        [[NSColor blackColor] set];
        NSRectFill(r);
        r = [[object endControlPoint] centerRect];
        [[NSColor blackColor] set];
        NSRectFill(r);
    }

    if([self isEditSelected])
    {
        NSRect r;

        r = [[object startControlPoint] centerRect];
        [[NSColor blackColor] set];
        NSRectFill(r);
        r = [[object endControlPoint] centerRect];
        [[NSColor blackColor] set];
        NSRectFill(r);

        if([[object startControlPoint] isSelect])
        {
            r = [[object startControlPoint] innerRect];
            [[NSColor whiteColor] set];
            NSRectFill(r);
        }
        if([[object endControlPoint] isSelect])
        {
            r = [[object endControlPoint] innerRect];
            [[NSColor whiteColor] set];
            NSRectFill(r);
        }
    }    
}

@end
