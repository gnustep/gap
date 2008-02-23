#import "GRBezierPathEditor.h"
#import "GRDocView.h"
#import "GRFunctions.h"

@implementation GRBezierPathEditor

- (id)initEditor:(GRBezierPath *)anObject
{
    self = [super init];
    if(self)
    {
        object = object;
        groupSelected = NO;
        editSelected = NO;
        isdone = NO;
        isvalid = NO;        
    }
    return self;
}





- (NSPoint)moveControlAtPoint:(NSPoint)p
{
    GRBezierControlPoint *cp, *pntonpnt;
    NSEvent *event;
    NSPoint pp;
    BOOL found = NO;
    int i;

    for(i = 0; i < [[object controlPoints] count]; i++)
    {
        cp = [[object controlPoints] objectAtIndex: i];
        if(pointInRect([cp centerRect], p))
        {
            [self selectForEditing];
            [object setCurrentPoint:cp];
            [cp select];
            found = YES;
        }
    }
    if(!found)
        return p;

    event = [[[object view] window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    if([event type] == NSLeftMouseDragged)
    {
        [[object view] verifyModifiersOfEvent: event];
        do {
            pp = [event locationInWindow];
            pp = [[object view] convertPoint: pp fromView: nil];
            if([[object view] shiftclick])
                pp = pointApplyingCostrainerToPoint(pp, p);

            pntonpnt = [object pointOnPoint: [object currentPoint]];
            if(pntonpnt) {
                if([object currentPoint] == [object firstPoint] || pntonpnt == [object firstPoint])
                    [pntonpnt moveToPoint: pp];
            }
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
    GRBezierControlPoint *cp, *pntonpnt;
    BOOL found = NO;
    int i;

    for(i = 0; i < [[object controlPoints] count]; i++)
    {
        cp = [[object controlPoints] objectAtIndex: i];
        if(pointInRect([cp centerRect], oldp))
        {
            [self selectForEditing];
            [object setCurrentPoint:cp];
            [cp select];
            found = YES;
        }
    }
    if(!found)
        return;

    pntonpnt = [object pointOnPoint: [object currentPoint]];
    if(pntonpnt)
    {
        if([object currentPoint] == [object firstPoint] || pntonpnt == [object firstPoint])
            [pntonpnt moveToPoint: newp];
    }
    [[object currentPoint] moveToPoint: newp];
    [object remakePath];
    [[object view] setNeedsDisplay: YES];
}

- (NSPoint)moveBezierHandleAtPoint:(NSPoint)p
{
    GRBezierControlPoint *cp, *pntonpnt;
    GRBezierHandle handle;
    BOOL found = NO;
    NSEvent *event;
    NSPoint op, pp, c;
    int i;

    if(!editSelected)
        return p;

    for(i = 0; i < [[object controlPoints] count]; i++)
    {
        cp = [[object controlPoints] objectAtIndex: i];
        if([cp isActiveHandle]) {
            handle = [cp bzHandle];
            if(pointInRect(handle.firstHandleRect, p)
               || pointInRect(handle.secondHandleRect, p))
            {
                [cp select];
                [object setCurrentPoint:cp];
                found = YES;
            }
        }
    }
    if(!found)
        return p;

    event = [[[object view] window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    if([event type] == NSLeftMouseDragged) {
        [[object view] verifyModifiersOfEvent: event];
        op.x = p.x;
        op.y = p.y;
        do {
            pp = [event locationInWindow];
            pp = [[object view] convertPoint: pp fromView: nil];
            if([[object view] shiftclick]) {
                c = [[object currentPoint] center];
                pp = pointApplyingCostrainerToPoint(pp, c);
            }

            pntonpnt = [object pointOnPoint: [object currentPoint]];
            if(pntonpnt) {
                if([object currentPoint] == [object firstPoint] || pntonpnt == [object firstPoint])
                    [pntonpnt moveBezierHandleToPosition: pp oldPosition: op];
            }
            [[object currentPoint] moveBezierHandleToPosition: pp oldPosition: op];
            [object remakePath];

            op.x = pp.x;
            op.y = pp.y;
            [[object view] setNeedsDisplay: YES];
            event = [[[object view] window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            [[object view] verifyModifiersOfEvent: event];
        } while([event type] != NSLeftMouseUp);
    }

    return pp;
}

- (void)moveBezierHandleAtPoint:(NSPoint)oldp toPoint:(NSPoint)newp
{
    GRBezierControlPoint *cp, *pntonpnt;
    GRBezierHandle handle;
    BOOL found = NO;
    int i;

    for(i = 0; i < [[object controlPoints] count]; i++)
    {
        cp = [[object controlPoints] objectAtIndex: i];
        if([cp isActiveHandle])
        {
            handle = [cp bzHandle];
            if(pointInRect(handle.firstHandleRect, oldp)
               || pointInRect(handle.secondHandleRect, oldp))
            {
                [cp select];
                [object setCurrentPoint:cp];
                found = YES;
            }
        }
    }
    if(!found)
        return;

    pntonpnt = [object pointOnPoint: [object currentPoint]];
    if(pntonpnt)
    {
        if([object currentPoint] == [object firstPoint] || pntonpnt == [object firstPoint])
            [pntonpnt moveBezierHandleToPosition: newp oldPosition: oldp];
    }
    [[object currentPoint] moveBezierHandleToPosition: newp oldPosition: oldp];
    [object remakePath];
    [[object view] setNeedsDisplay: YES];
}

- (void)moveAddingCoordsOfPoint:(NSPoint)p
{
    int i;

    for(i = 0; i < [[object controlPoints] count]; i++)
    {
        GRBezierControlPoint *cp = [[object controlPoints] objectAtIndex: i];
        [cp moveToPoint: NSMakePoint([cp center].x + p.x, [cp center].y + p.y)];
    }
    [object remakePath];
}


- (BOOL)isdone
{
    return isdone;
}

- (void)setIsDone:(BOOL)status
{
    isdone = status;
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
        [[object view] unselectOtherObjects: self];
    }
}

- (void)selectForEditing
{
    if([object locked])
        return;
    editSelected = YES;
    groupSelected = NO;
    isvalid = NO;
    [[object view] unselectOtherObjects: self];
}

- (void)unselect
{
    int i;

    groupSelected = NO;
    editSelected = NO;
    isvalid = YES;
    isdone = YES;
    for(i = 0; i < [[object controlPoints] count]; i++)
        [[[object controlPoints] objectAtIndex: i] unselect];
}

- (BOOL)isGroupSelected
{
    return groupSelected;
}

- (BOOL)isEditSelected
{
    return editSelected;
}

- (BOOL)isSelect
{
    if(editSelected || groupSelected)
        return YES;
    return NO;
}

- (void)unselectOtherControls:(GRBezierControlPoint *)cp
{
    GRBezierControlPoint *ctrlp;
    int i;

    [object setCurrentPoint:cp];
    for(i = 0; i < [[object controlPoints] count]; i++) {
        ctrlp = [[object controlPoints] objectAtIndex: i];
        if(ctrlp != cp)
            [ctrlp unselect];
    }
}

- (void)setIsValid:(BOOL)value
{
    isvalid = value;
}

- (BOOL)isValid
{
    return isvalid;
}

- (void)draw
{
    GRBezierControlPoint *cp, *ponpoint = nil;
    NSRect r;
    GRBezierHandle bzhandle;
    int i;
    NSBezierPath *bzp;

    if(![[object controlPoints] count] || ![object visible])
        return;

    bzp = [NSBezierPath bezierPath];

    [bzp setLineWidth:1];
    if(groupSelected)
    {
        for(i = 0; i < [[object controlPoints] count]; i++)
        {
            cp = [[object controlPoints] objectAtIndex: i];
            r = [cp centerRect];
            [[NSColor blackColor] set];
            NSRectFill(r);
        }
    }

    if(editSelected)
    {
        for(i = 0; i < [[object controlPoints] count]; i++)
        {
            cp = [[object controlPoints] objectAtIndex: i];
            r = [cp centerRect];
            if([cp isSelect]) {
                [[NSColor blackColor] set];
                NSRectFill(r);
                if([cp isActiveHandle]) {
                    bzhandle = [cp bzHandle];
                    [[NSColor blackColor] set];
                    NSRectFill(bzhandle.firstHandleRect);
                    [bzp moveToPoint:NSMakePoint(bzhandle.firstHandle.x, bzhandle.firstHandle.y)];
                    [bzp lineToPoint:NSMakePoint(bzhandle.center.x, bzhandle.center.y)];
                    [bzp lineToPoint:NSMakePoint(bzhandle.secondHandle.x, bzhandle.secondHandle.y)];
                    [bzp stroke];
                    NSRectFill(bzhandle.secondHandleRect);
                }
            } else
            {
                [[NSColor whiteColor] set];
                NSRectFill(r);

                ponpoint = [object pointOnPoint: cp];
                if(ponpoint)
                {
                    if([ponpoint isSelect])
                    {
                        r = [ponpoint centerRect];
                        [[NSColor blackColor] set];
                        NSRectFill(r);
                        if([ponpoint isActiveHandle])
                        {
                            bzhandle = [ponpoint bzHandle];
                            [[NSColor blackColor] set];
                            NSRectFill(bzhandle.firstHandleRect);
                            [bzp moveToPoint:NSMakePoint(bzhandle.firstHandle.x, bzhandle.firstHandle.y)];
                            [bzp lineToPoint:NSMakePoint(bzhandle.center.x, bzhandle.center.y)];
                            [bzp lineToPoint:NSMakePoint(bzhandle.secondHandle.x, bzhandle.secondHandle.y)];
                            [bzp stroke];
                            NSRectFill(bzhandle.secondHandleRect);
                        }
                    }
                }

            }
            [[NSColor blackColor] set];
            NSFrameRect(r);
        }
    }
}

@end



