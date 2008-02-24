//
//  GRBox.m
//  Graphos
//
//  Created by Riccardo Mottola on Fri Sep 21 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GRBox.h"
#import "GRBoxEditor.h"

@implementation GRBox

- (id)initInView:(GRDocView *)aView
         atPoint:(NSPoint)p
      zoomFactor:(float)zf
{
    int result;

    self = [super init];
    if(self)
    {
        myView = aView;
        zmFactor = zf;
        myPath = [[NSBezierPath bezierPath] retain];
        [myPath setCachesBezierPath: NO];
        pos = NSMakePoint(p.x / zf, p.y / zf);
        rotation = 0;
        scalex = 1;
        scaley = 1;
        groupSelected = NO;
        editSelected = NO;
        isdone = NO;
        flatness = 0.0;
        miterlimit = 2.0;
        linewidth = 1.5;
        linejoin = 0;
        linecap = 0;
        stroked = YES;
        filled = NO;
        visible = YES;
        locked = NO;
        isvalid = NO;
        strokeColor[0] = 0;
        strokeColor[1] = 0;
        strokeColor[2] = 0;
        strokeColor[3] = 1;
        fillColor[0] = 0;
        fillColor[1] = 0;
        fillColor[2] = 0;
        fillColor[3] = 0;
        strokeAlpha = 1;
        fillAlpha = 1;
        editor = [[GRBoxEditor alloc] initEditor:(GRBox*)self];
    }

    return self;
}

- (GRBoxEditor *)editor
{
    return editor;
}

- (BOOL)locked
{
    return locked;
}

- (void)setLocked:(BOOL)value
{
    locked = value;
    if(!locked)
        [editor unselect];
    else
        [editor selectAsGroup];
}

- (GRDocView *)view
{
    return myView;
}

- (void)draw
{
    //    GRBezierControlPoint *cp, *ponpoint = nil;
    NSRect r;
    //    GRBezierHandle bzhandle;
    NSColor *color;
    int i;
    NSBezierPath *bzp;


    bzp = [NSBezierPath bezierPath];
    if(stroked)
    {
        NSLog(@"line width: %f", linewidth);
        [NSGraphicsContext saveGraphicsState];
        [myPath setLineJoinStyle:linejoin];
        [myPath setLineCapStyle:linecap];
        [myPath setLineWidth:linewidth];
        // #### and alpha strokeAlpha ????
        color = [NSColor colorWithDeviceCyan: strokeColor[0]
                                     magenta: strokeColor[1]
                                      yellow: strokeColor[2]
                                       black: strokeColor[3]
                                       alpha: strokeAlpha];
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        [color set];
        [myPath stroke];   // FIXME why this twice... need to understand mypath
        [NSGraphicsContext restoreGraphicsState];
    }

    if(filled)
    {
        // #### and alpha strokeAlpha ????
        [NSGraphicsContext saveGraphicsState];
        //		PSsetalpha(fillAlpha);
        color = [NSColor colorWithDeviceCyan: fillColor[0]
                                     magenta: fillColor[1]
                                      yellow: fillColor[2]
                                       black: fillColor[3]
                                       alpha: fillAlpha];
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        [color set];
        [myPath fill];
        [NSGraphicsContext restoreGraphicsState];
    }

    [bzp setLineWidth:1];
    if(groupSelected)
    {
        /*        for(i = 0; i < [controlPoints count]; i++)
    {
            cp = [controlPoints objectAtIndex: i];
            r = [cp centerRect];
            [[NSColor blackColor] set];
            NSRectFill(r);
    } */
    }

    if(editSelected)
    {
        /*        for(i = 0; i < [controlPoints count]; i++)
    {
            cp = [controlPoints objectAtIndex: i];
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

                ponpoint = [self pointOnPoint: cp];
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
    } */
    }
}


@end
