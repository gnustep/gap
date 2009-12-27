/*
 Project: Graphos
 GRBoxEditor.m

 Copyright (C) 2007-2009 GNUstep Application Project

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
#import "GRFunctions.h"

@implementation GRBoxEditor

- (id)initEditor:(GRDrawableObject *)anObject
{
    self = [super initEditor:anObject];
    if(self != nil)
    {
    }
    return self;
}


- (NSPoint)moveControlAtPoint:(NSPoint)p
{
    GRObjectControlPoint *cp;
    NSEvent *event;
    NSPoint pp;
    BOOL found = NO;

    cp = [(GRBox *)object startControlPoint];
    if (pointInRect([cp centerRect], p))
    {
        [self selectForEditing];
        [(GRPathObject *)object setCurrentPoint:cp];
        [cp select];
        found =  YES;
    }
    cp = [(GRBox *)object endControlPoint];
    if (pointInRect([cp centerRect], p))
    {
        [self selectForEditing];
        [(GRPathObject *)object setCurrentPoint:cp];
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
            [[(GRPathObject *)object currentPoint] moveToPoint: pp];
            [(GRPathObject *)object remakePath];

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
    GRObjectControlPoint *cp;
    BOOL found = NO;

    cp = [(GRBox *)object startControlPoint];
    if (pointInRect([cp centerRect], oldp))
    {
        [self selectForEditing];
        [(GRPathObject *)object setCurrentPoint:cp];
        [cp select];
        found =  YES;
    }
    cp = [(GRBox *)object endControlPoint];
    if (pointInRect([cp centerRect], oldp))
    {
        [self selectForEditing];
        [(GRBox *)object setCurrentPoint:cp];
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
    [[(GRPathObject *)object currentPoint] moveToPoint: newp];
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

        r = [[(GRBox *)object startControlPoint] centerRect];
        [[NSColor blackColor] set];
        NSRectFill(r);
        r = [[(GRBox *)object endControlPoint] centerRect];
        [[NSColor blackColor] set];
        NSRectFill(r);
    }

    if([self isEditSelected])
    {
        NSRect r;

        r = [[(GRBox *)object startControlPoint] centerRect];
        [[NSColor blackColor] set];
        NSRectFill(r);
        r = [[(GRBox *)object endControlPoint] centerRect];
        [[NSColor blackColor] set];
        NSRectFill(r);

        if([[(GRBox *)object startControlPoint] isSelect])
        {
            r = [[(GRBox *)object startControlPoint] innerRect];
            [[NSColor whiteColor] set];
            NSRectFill(r);
        }
        if([[(GRBox *)object endControlPoint] isSelect])
        {
            r = [[(GRBox *)object endControlPoint] innerRect];
            [[NSColor whiteColor] set];
            NSRectFill(r);
        }
    }    
}

@end
