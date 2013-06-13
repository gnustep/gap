/*
 Project: Graphos
 GRCircleEditor.m

 Copyright (C) 2009-2013 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2009-12-27

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

#import "GRCircleEditor.h"
#import "GRDocView.h"
#import "GRFunctions.h"


@implementation GRCircleEditor

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

    cp = [(GRCircle *)object startControlPoint];
    if (pointInRect([cp centerRect], p))
    {
        [self selectForEditing];
        [(GRPathObject *)object setCurrentPoint:cp];
        [cp select];
        found =  YES;
    }
    cp = [(GRCircle *)object endControlPoint];
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
            if([[object view] shiftclick])
              {
                NSPoint pos;
                CGFloat w, h;

                pos = [(GRCircle *)object position];
                w = pos.x-pp.x;
                h = pos.y-pp.y;

                if (w < h)
                  pp.y = pos.y+w;
                else
                  pp.x = pos.x+h;
              }
            
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


- (void)draw
{
  NSBezierPath *bzp;
  
  if(![object visible])
    return;
  
  bzp = [NSBezierPath bezierPath];
  
  if([self isGroupSelected])
    {
      [[(GRCircle *)object startControlPoint] drawControlAsSelected:NO];
      [[(GRCircle *)object endControlPoint] drawControlAsSelected:NO];
    }
  
  if([self isEditSelected])
    { 
      [bzp appendBezierPathWithRect:[(GRCircle *)object bounds]];
      [bzp setLineWidth:0.2];
      [[NSColor lightGrayColor] set];
      [bzp stroke];
      
      [[(GRCircle *)object startControlPoint] drawControl];
      [[(GRCircle *)object endControlPoint] drawControl];
    }
}

@end
