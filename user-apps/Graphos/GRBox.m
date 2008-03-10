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
      zoomFactor:(float)zf
{
    int result;

    self = [super init];
    if(self)
    {
        docView = aView;
        zmFactor = zf;
        myPath = [[NSBezierPath bezierPath] retain];
        [myPath setCachesBezierPath: NO];
        pos = NSMakePoint(0, 0);
	size = NSMakeSize(0, 0);
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


- (void)setStartAtPoint:(NSPoint)aPoint
{
    pos = aPoint;
/*    GRBezierControlPoint *cp;

    cp = [[GRBezierControlPoint alloc] initAtPoint: aPoint
                                         forPath: self zoomFactor: zmFactor];
    [controlPoints addObject: cp];
    [cp select];
    currentPoint = cp;
    [cp release];

    if([controlPoints count] == 1)
        [myPath moveToPoint: aPoint];
	*/
}

- (void)setEndAtPoint:(NSPoint)aPoint
{
    size.width = aPoint.x - pos.x;
    size.height = aPoint.y- pos.y;
    bounds = NSMakeRect(pos.x, pos.y, size.width, size.height);
/*    GRBezierControlPoint *mtopoint, *prevpoint;
    GRBezierHandle handle;

    [self addControlAtPoint: aPoint];
    mtopoint = [controlPoints objectAtIndex: 0];
    prevpoint = [controlPoints objectAtIndex: [controlPoints count] -2];

    if([prevpoint isActiveHandle])
    {
        handle = [prevpoint bzHandle];
        [myPath curveToPoint: [currentPoint center]
               controlPoint1: handle.firstHandle
               controlPoint2: [currentPoint center]];
        [self confirmNewCurve];
        return;
    }

    if([self isPoint: currentPoint onPoint: mtopoint])
    {
        [currentPoint moveToPoint: [mtopoint center]];
        [myPath lineToPoint: [mtopoint center]];
        [editor setIsDone:YES];
    } else {
        [myPath lineToPoint: aPoint];
    } */
}

- (void)setFlat:(float)flat
{
    flatness = flat;
}

- (float)flatness
{
    return flatness;
}

- (void)setLineJoin:(int)join
{
    linejoin = join;
}

- (int)lineJoin
{
    return linejoin;
}

- (void)setLineCap:(int)cap
{
    linecap = cap;
}

- (int)lineCap
{
    return linecap;
}

- (void)setMiterLimit:(float)limit
{
    miterlimit = limit;
}

- (float)miterLimit
{
    return miterlimit;
}

- (void)setLineWidth:(float)width
{
    linewidth = width;
}

- (float)lineWidth
{
    return linewidth;
}

- (void)setStroked:(BOOL)value
{
    stroked = value;
}

- (BOOL)isStroked
{
    return stroked;
}

- (void)setStrokeColor:(float *)c
{
    int i;

    for(i = 0; i < 4; i++)
        strokeColor[i] = c[i];
}

- (float *)strokeColor
{
    return strokeColor;
}

- (void)setStrokeAlpha:(float)alpha
{
    strokeAlpha = alpha;
}

- (float)strokeAlpha
{
    return strokeAlpha;
}

- (void)setFilled:(BOOL)value
{
    filled = value;
}

- (BOOL)isFilled
{
    return filled;
}

- (void)setFillColor:(float *)c
{
    int i;

    for(i = 0; i < 4; i++)
        fillColor[i] = c[i];
}

- (float *)fillColor
{
    return fillColor;
}

- (void)setFillAlpha:(float)alpha
{
    fillAlpha = alpha;
}

- (float)fillAlpha
{
    return fillAlpha;
}


- (void)setLocked:(BOOL)value
{
    [super setLocked:value];
    if(!locked)
        [editor unselect];
    else
        [editor selectAsGroup];
}

- (BOOL)pointInBounds:(NSPoint)p
{
    return (pointInRect(bounds, p));
}


- (void)draw
{
    NSColor *color;
    int i;
    NSBezierPath *bzp;

    NSLog(@"position %f, %f, size %f, %f", pos.x, pos.y, size.width, size.height);

    bzp = [NSBezierPath bezierPath];
    [bzp appendBezierPathWithRect:bounds];
    if(stroked)
    {
        NSLog(@"line width: %f", linewidth);
        [NSGraphicsContext saveGraphicsState];
        [bzp setLineJoinStyle:linejoin];
        [bzp setLineCapStyle:linecap];
        [bzp setLineWidth:linewidth];
        color = [NSColor colorWithDeviceCyan: strokeColor[0]
                                     magenta: strokeColor[1]
                                      yellow: strokeColor[2]
                                       black: strokeColor[3]
                                       alpha: strokeAlpha];
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        [color set];
        [bzp stroke]; 
        [NSGraphicsContext restoreGraphicsState];
    }

    if(filled)
    {
        [NSGraphicsContext saveGraphicsState];
        color = [NSColor colorWithDeviceCyan: fillColor[0]
                                     magenta: fillColor[1]
                                      yellow: fillColor[2]
                                       black: fillColor[3]
                                       alpha: fillAlpha];
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        [color set];
        [bzp fill];
        [NSGraphicsContext restoreGraphicsState];
    }

    [bzp setLineWidth:1];

    if(editSelected)
    {
        // put in here code to draw handles
    }
}


@end
