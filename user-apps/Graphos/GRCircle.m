/*
 Project: Graphos
 GRCircle.m

 Copyright (C) 2009-2012 GNUstep Application Project

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

#import <AppKit/NSColor.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSGraphicsContext.h>
#import "GRCircle.h"
#import "GRCircleEditor.h"
#import "GRFunctions.h"

@implementation GRCircle


/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(float)zf
  withProperties:(NSDictionary *)properties
{
  self = [super initInView:aView zoomFactor:zf withProperties:properties];
  if(self)
    {
      NSLog(@"initInView properties of GRCircle");

      pos = NSMakePoint(0, 0);
      size = NSMakeSize(0, 0);
      startControlPoint = nil;
      endControlPoint = nil;
      rotation = 0;

      editor = [[GRCircleEditor alloc] initEditor:self];
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
	float strokeCol[4];
	float fillCol[4];
	float strokeAlpha;
	float fillAlpha;
	id obj;

        docView = aView;
        editor = [[GRCircleEditor alloc] initEditor:(GRCircle*)self];
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
	strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];
        str = [description objectForKey: @"strokecolor"];
        linearr = [str componentsSeparatedByString: @" "];
	if ([linearr count] == 3)
	  {
	    strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
	    strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
	    strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
	    strokeColor = [NSColor colorWithCalibratedRed: strokeCol[0]
				   green: strokeCol[1]
				   blue: strokeCol[2]
				   alpha: strokeAlpha];
	    [strokeColor retain];
	  }
	else
	  {
	    strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
	    strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
	    strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
	    strokeCol[3] = [[linearr objectAtIndex: 3] floatValue];
	    strokeColor = [NSColor colorWithDeviceCyan: strokeCol[0]
				   magenta: strokeCol[1]
				   yellow: strokeCol[2]
				   black: strokeCol[3]
				   alpha: strokeAlpha];
	    strokeColor = [[strokeColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
	  }
	obj = [description objectForKey: @"filled"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];	
        filled = [obj boolValue];
        fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];
        str = [description objectForKey: @"fillcolor"];
        linearr = [str componentsSeparatedByString: @" "];
	if ([linearr count] == 3)
	  {
	    fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
	    fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
	    fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
	    fillColor = [NSColor colorWithCalibratedRed: fillCol[0]
				 green: fillCol[1]
				 blue: fillCol[2]
				 alpha: fillAlpha];
	    [fillColor retain];
	  }
	else
	  {
	    fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
	    fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
	    fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
	    fillCol[3] = [[linearr objectAtIndex: 3] floatValue];
	    fillColor = [NSColor colorWithDeviceCyan: fillCol[0]
				 magenta: fillCol[1]
				 yellow: fillCol[2]
				 black: fillCol[3]
				 alpha: fillAlpha];
	    fillColor = [[fillColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
	  }
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
    GRCircle *objCopy;

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
    float strokeCol[3];
    float fillCol[3];
    float strokeAlpha;
    float fillAlpha;

    strokeCol[0] = [strokeColor redComponent];
    strokeCol[1] = [strokeColor greenComponent];
    strokeCol[2] = [strokeColor blueComponent];
    strokeAlpha = [strokeColor alphaComponent];

    fillCol[0] = [fillColor redComponent];
    fillCol[1] = [fillColor greenComponent];
    fillCol[2] = [fillColor blueComponent];
    fillAlpha = [fillColor alphaComponent];

    dict = [NSMutableDictionary dictionaryWithCapacity: 1];
    [dict setObject: @"circle" forKey: @"type"];

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
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f",
        strokeCol[0], strokeCol[1], strokeCol[2]];
    [dict setObject: str forKey: @"strokecolor"];
    str = [NSString stringWithFormat: @"%.3f", strokeAlpha];
    [dict setObject: str forKey: @"strokealpha"];
    str = [NSString stringWithFormat: @"%i", filled];
    [dict setObject: str forKey: @"filled"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f",
        fillCol[0], fillCol[1], fillCol[2]];
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
    [(GRCircleEditor *)editor setIsDone:YES];
}


- (void)setLocked:(BOOL)value
{
    [super setLocked:value];
    if(!locked)
        [(GRCircleEditor *)editor unselect];
    else
        [(GRCircleEditor *)editor selectAsGroup];
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

    [startControlPoint setZoomFactor:f];
    [endControlPoint setZoomFactor:f];
    [self remakePath];
}

/** bounds accessor */
- (NSRect)bounds
{
    return bounds;
}

/** draws the object and calls the editor to draw itself afterwards */
- (void)draw
{
  NSBezierPath *bzp;
  NSPoint center;
  float radius;
  float w,h;
  float minLength;
  float linew;

  linew = linewidth * zmFactor;

    center = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
    w = NSWidth(bounds);
    h = NSHeight(bounds);
    if (w > h)
        minLength = h;
    else
        minLength = w;
    radius = minLength / 2;

    bzp = [NSBezierPath bezierPath];
    [bzp appendBezierPathWithArcWithCenter:center radius:radius startAngle:0 endAngle:360];
    
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
      [bzp setLineWidth:linew];
      [strokeColor set];
      [bzp stroke]; 
      [NSGraphicsContext restoreGraphicsState];
    }
    
    if ([[NSGraphicsContext currentContext] isDrawingToScreen])
        [editor draw];
}


@end
