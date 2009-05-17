/*
 Project: Graphos
 GRBox.m

 Copyright (C) 2007-2009 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2007-09-21

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

#import "GRBox.h"
#import "GRBoxEditor.h"
#import "GRFunctions.h"


@implementation GRBox

- (id)initInView:(GRDocView *)aView
      zoomFactor:(float)zf
{
    self = [super init];
    if(self)
    {
        docView = aView;
        zmFactor = zf;
        myPath = [[NSBezierPath bezierPath] retain];
        [myPath setCachesBezierPath: NO];
        pos = NSMakePoint(0, 0);
	size = NSMakeSize(0, 0);
        startControlPoint = nil;
        endControlPoint = nil;
        rotation = 0;
        flatness = 0.0;
        miterlimit = 2.0;
        linewidth = 1.5;
        linejoin = 0;
        linecap = 0;
        stroked = YES;
        filled = NO;
        visible = YES;
        locked = NO;
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
        startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zf];
        endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zf];
    }

    return self;
}

/** initializes all parameters from a description dictionary */
- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(float)zf
{
    NSString *str;
    NSArray *linearr;

    self = [super init];
    if(self)
    {
        docView = aView;
        editor = [[GRBoxEditor alloc] initEditor:(GRBox*)self];
        pos = NSMakePoint([[description objectForKey: @"posx"]  floatValue],
                          [[description objectForKey: @"posy"]  floatValue]);
        size = NSMakeSize([[description objectForKey: @"width"]  floatValue],
                          [[description objectForKey: @"height"]  floatValue]);
        bounds = GRMakeBounds(pos.x, pos.y, size.width, size.height);
        rotation = [[description objectForKey: @"rotation"] floatValue];

        flatness = [[description objectForKey: @"flatness"] floatValue];
        linejoin = [[description objectForKey: @"linejoin"] intValue];
        linecap = [[description objectForKey: @"linecap"] intValue];
        miterlimit = [[description objectForKey: @"miterlimit"] floatValue];
        linewidth = [[description objectForKey: @"linewidth"] floatValue];

        stroked = (BOOL)[[description objectForKey: @"stroked"] intValue];
        str = [description objectForKey: @"strokecolor"];
        linearr = [str componentsSeparatedByString: @" "];
        strokeColor[0] = [[linearr objectAtIndex: 0] floatValue];
        strokeColor[1] = [[linearr objectAtIndex: 1] floatValue];
        strokeColor[2] = [[linearr objectAtIndex: 2] floatValue];
        strokeColor[3] = [[linearr objectAtIndex: 3] floatValue];
        strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];

        filled = (BOOL)[[description objectForKey: @"filled"] intValue];
        str = [description objectForKey: @"fillcolor"];
        linearr = [str componentsSeparatedByString: @" "];
        fillColor[0] = [[linearr objectAtIndex: 0] floatValue];
        fillColor[1] = [[linearr objectAtIndex: 1] floatValue];
        fillColor[2] = [[linearr objectAtIndex: 2] floatValue];
        fillColor[3] = [[linearr objectAtIndex: 3] floatValue];
        fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];

        visible = (BOOL)[[description objectForKey: @"visible"] intValue];
        locked = (BOOL)[[description objectForKey: @"locked"] intValue];
        startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zf];
        endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zf];
        [self setZoomFactor: zf];
    }
    return self;
}

- (void)dealloc
{
    [startControlPoint dealloc];
    [endControlPoint dealloc];
    [super dealloc];
}

- (NSDictionary *)objectDescription
{
    NSMutableDictionary *dict;
    NSString *str;

    dict = [NSMutableDictionary dictionaryWithCapacity: 1];
    [dict setObject: @"box" forKey: @"type"];

    str = [NSString stringWithFormat: @"%.3f", pos.x];
    [dict setObject: str forKey: @"posx"];
    str = [NSString stringWithFormat: @"%.3f", pos.y];
    [dict setObject: str forKey: @"posy"];
    
    str = [NSString stringWithFormat: @"%.3f", size.width];
    [dict setObject: str forKey: @"width"];
    str = [NSString stringWithFormat: @"%.3f", size.height];
    [dict setObject: str forKey: @"height"];

    str = [NSString stringWithFormat: @"%.3f", flatness];
    [dict setObject: str forKey: @"flatness"];
    str = [NSString stringWithFormat: @"%i", linejoin];
    [dict setObject: str forKey: @"linejoin"];
    str = [NSString stringWithFormat: @"%i", linecap];
    [dict setObject: str forKey: @"linecap"];
    str = [NSString stringWithFormat: @"%.3f", miterlimit];
    [dict setObject: str forKey: @"miterlimit"];
    str = [NSString stringWithFormat: @"%.3f", linewidth];
    [dict setObject: str forKey: @"linewidth"];
    str = [NSString stringWithFormat: @"%i", stroked];
    [dict setObject: str forKey: @"stroked"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f",
        strokeColor[0], strokeColor[1], strokeColor[2], strokeColor[3]];
    [dict setObject: str forKey: @"strokecolor"];
    str = [NSString stringWithFormat: @"%.3f", strokeAlpha];
    [dict setObject: str forKey: @"strokealpha"];
    str = [NSString stringWithFormat: @"%i", filled];
    [dict setObject: str forKey: @"filled"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f",
        fillColor[0], fillColor[1], fillColor[2], fillColor[3]];
    [dict setObject: str forKey: @"fillcolor"];
    str = [NSString stringWithFormat: @"%.3f", fillAlpha];
    [dict setObject: str forKey: @"fillalpha"];
    str = [NSString stringWithFormat: @"%i", visible];
    [dict setObject: str forKey: @"visible"];
    str = [NSString stringWithFormat: @"%i", locked];
    [dict setObject: str forKey: @"locked"];

    return dict;
}

- (void)setStartAtPoint:(NSPoint)aPoint
{
    pos = aPoint;
    [startControlPoint moveToPoint: aPoint];
    [startControlPoint select];
}

- (void)setEndAtPoint:(NSPoint)aPoint
{
    size.width = aPoint.x - pos.x;
    size.height = aPoint.y- pos.y;
    bounds = GRMakeBounds(pos.x, pos.y, size.width, size.height);
    [endControlPoint moveToPoint: aPoint];
    [endControlPoint select];
}

- (void)remakePath
{
    [self setStartAtPoint:[startControlPoint center]];
    [self setEndAtPoint:[endControlPoint center]];
    [(GRBoxEditor *)editor setIsDone:YES];
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
        [(GRBoxEditor *)editor unselect];
    else
        [(GRBoxEditor *)editor selectAsGroup];
}

- (BOOL)pointInBounds:(NSPoint)p
{
    return (pointInRect(bounds, p));
}

- (BOOL)onControlPoint:(NSPoint)p
{
    if (pointInRect([startControlPoint centerRect], p))
        return YES;
    if (pointInRect([endControlPoint centerRect], p))
        return YES;
    return NO;
}

- (GRObjectControlPoint *) startControlPoint
{
    return startControlPoint;
}

- (GRObjectControlPoint *) endControlPoint
{
    return endControlPoint;
}


- (void)moveAddingCoordsOfPoint:(NSPoint)p
{
    pos.x += p.x;
    pos.y += p.y;
    bounds = GRMakeBounds(pos.x, pos.y, size.width, size.height);
    [startControlPoint moveToPoint: pos];
    [endControlPoint moveToPoint: NSMakePoint(pos.x + size.width, pos.y + size.height)];
}

- (void)setZoomFactor:(float)f
{
    [super setZoomFactor:f];

    linewidth = linewidth / zmFactor * f;

    [startControlPoint setZoomFactor:f];
    [endControlPoint setZoomFactor:f];
    [self remakePath];
}

/** draws the object and calls the editor to draw itself afterwards */
- (void)draw
{
    NSColor *color;
    NSBezierPath *bzp;


    bzp = [NSBezierPath bezierPath];
    [bzp appendBezierPathWithRect:bounds];
    if(stroked)
    {
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
    
    if ([[NSGraphicsContext currentContext] isDrawingToScreen])
        [editor draw];
}


@end
