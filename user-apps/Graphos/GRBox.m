/*
 Project: Graphos
 GRBox.m

 Copyright (C) 2007-2012 GNUstep Application Project

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

#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSGraphicsContext.h>
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
        strokeColor = [[NSColor blackColor] retain];
        fillColor = [[NSColor whiteColor] retain];
        editor = [[GRBoxEditor alloc] initEditor:(GRBox*)self];
        startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zf];
        endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zf];
      }

    return self;
}

/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(float)zf
      withProperties:(NSDictionary *)properties
{
  self = [self initInView:aView zoomFactor:zf];
  if(self)
    {
      NSColor *newColor;
      id val;

      val = [properties objectForKey: @"flatness"];
      if (val != nil)
	[self setFlat: [val floatValue]];

      val = [properties objectForKey: @"linejoin"];
      if (val != nil)
	[self setLineJoin: [val intValue]];

      val = [properties objectForKey: @"linecap"];
      if (val != nil)
	[self setLineCap: [val intValue]];

      val = [properties objectForKey: @"miterlimit"];
      if (val != nil)
	[self setMiterLimit: [val floatValue]];

      val = [properties objectForKey: @"linewidth"];
      if (val != nil)
        [self setLineWidth: [val floatValue]];

      val = [properties objectForKey: @"stroked"];
      if (val != nil)
	[self setStroked: [val boolValue]];
      newColor = (NSColor *)[properties objectForKey: @"strokecolor"];
      if (newColor != nil)
	[self setStrokeColor: newColor];

      val = [properties objectForKey: @"filled"];
      if (val != nil)
	[self setFilled: [val boolValue]];
      newColor = (NSColor *)[properties objectForKey: @"fillcolor"];
      if (newColor != nil)
	[self setFillColor: newColor];
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
	float strokeCol[4];
	float fillCol[4];
	float strokeAlpha;
	float fillAlpha;
	id obj;

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
        obj = [description objectForKey: @"stroked"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];
        stroked = [obj boolValue];
        str = [description objectForKey: @"strokecolor"];
        linearr = [str componentsSeparatedByString: @" "];

        strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
        strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
        strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
        strokeCol[3] = [[linearr objectAtIndex: 3] floatValue];
        strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];
	strokeColor = [NSColor colorWithDeviceCyan: strokeCol[0]
					   magenta: strokeCol[1]
					    yellow: strokeCol[2]
					     black: strokeCol[3]
					     alpha: strokeAlpha];
	strokeColor = [[strokeColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];

	obj = [description objectForKey: @"filled"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];	
        filled = [obj boolValue];
        str = [description objectForKey: @"fillcolor"];
        linearr = [str componentsSeparatedByString: @" "];
        fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
        fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
        fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
        fillCol[3] = [[linearr objectAtIndex: 3] floatValue];
        fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];
	fillColor = [NSColor colorWithDeviceCyan: fillCol[0]
					 magenta: fillCol[1]
					  yellow: fillCol[2]
					   black: fillCol[3]
					   alpha: fillAlpha];
	fillColor = [[fillColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];

	obj = [description objectForKey: @"visible"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];	
        visible = [obj boolValue];
	obj = [description objectForKey: @"locked"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];
        locked = [obj boolValue];
        startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zf];
        endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zf];
        [self setZoomFactor: zf];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GRBox *objCopy;
    
    objCopy = [super copyWithZone:zone];

    objCopy->startControlPoint = [[GRObjectControlPoint alloc] initAtPoint: pos zoomFactor:zmFactor];
    objCopy->endControlPoint = [[GRObjectControlPoint alloc] initAtPoint: NSMakePoint(pos.x + size.width, pos.y + size.height) zoomFactor:zmFactor];
    
    return objCopy;
}

- (void)dealloc
{
    [startControlPoint release];
    [endControlPoint release];
    [super dealloc];
}

- (NSDictionary *)objectDescription
{
    NSMutableDictionary *dict;
    NSString *str;
    NSColor *strokeColorCMYK;
    NSColor *fillColorCMYK;
    float strokeCol[4];
    float fillCol[4];
    float strokeAlpha;
    float fillAlpha;

    strokeColorCMYK = [strokeColor colorUsingColorSpaceName: NSDeviceCMYKColorSpace]; 
    strokeCol[0] = [strokeColorCMYK cyanComponent];
    strokeCol[1] = [strokeColorCMYK magentaComponent];
    strokeCol[2] = [strokeColorCMYK yellowComponent];
    strokeCol[3] = [strokeColorCMYK blackComponent];
    strokeAlpha = [strokeColorCMYK alphaComponent];

    fillColorCMYK = [fillColor colorUsingColorSpaceName: NSDeviceCMYKColorSpace]; 
    fillCol[0] = [fillColorCMYK cyanComponent];
    fillCol[1] = [fillColorCMYK magentaComponent];
    fillCol[2] = [fillColorCMYK yellowComponent];
    fillCol[3] = [fillColorCMYK blackComponent];
    fillAlpha = [fillColorCMYK alphaComponent];

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
    [dict setObject:[NSNumber numberWithBool:stroked]  forKey: @"stroked"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f",
        strokeCol[0], strokeCol[1], strokeCol[2], strokeCol[3]];
    [dict setObject: str forKey: @"strokecolor"];
    str = [NSString stringWithFormat: @"%.3f", strokeAlpha];
    [dict setObject: str forKey: @"strokealpha"];
    [dict setObject:[NSNumber numberWithBool:filled] forKey: @"filled"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f",
        fillCol[0], fillCol[1], fillCol[2], fillCol[3]];
    [dict setObject: str forKey: @"fillcolor"];
    str = [NSString stringWithFormat: @"%.3f", fillAlpha];
    [dict setObject: str forKey: @"fillalpha"];
    [dict setObject:[NSNumber numberWithBool:visible] forKey: @"visible"];
    [dict setObject:[NSNumber numberWithBool:locked] forKey: @"locked"];

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
    NSBezierPath *bzp;

    bzp = [NSBezierPath bezierPath];
    [bzp appendBezierPathWithRect:bounds];
    if(filled)
    {
        [NSGraphicsContext saveGraphicsState];
        [fillColor set];
        [bzp fill];
        [NSGraphicsContext restoreGraphicsState];
    }
    if(stroked)
    {
      [NSGraphicsContext saveGraphicsState];
      [bzp setLineJoinStyle:linejoin];
      [bzp setLineCapStyle:linecap];
      [bzp setLineWidth:linewidth];
      [strokeColor set];
      [bzp stroke]; 
      [NSGraphicsContext restoreGraphicsState];
    }
    
    if ([[NSGraphicsContext currentContext] isDrawingToScreen])
        [editor draw];
}


@end
