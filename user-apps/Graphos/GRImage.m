/*
 Project: Graphos
 GRImage.m
 
 Copyright (C) 2015 GNUstep Application Project
 
 Author: Ing. Riccardo Mottola
 
 Created: 2015-01-16
 
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

#import "GRImage.h"
#import "GRImageEditor.h"


#import <AppKit/AppKit.h>
#import "GRObjectEditor.h"

@implementation GRImage

- (GRObjectEditor *)allocEditor
{
  return [[GRImageEditor alloc] initEditor:self];
}

/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(CGFloat)zf
      withProperties:(NSDictionary *)properties
{
  self = [super initInView:aView zoomFactor:zf withProperties:properties];
  if(self)
    {
      NSData *imgRepData;

      imgRepData = [properties objectForKey:@"imgrepdata"];
      if (imgRepData)
        {
          NSImage *img;
          NSLog(@"GRImage: we have an image representation");

          img = [[NSImage alloc] initWithData:imgRepData];
          [self setImage: img];
          [img release];
        }
    }

  return self;
}


/** initializes all parameters from a description dictionary */
- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(CGFloat)zf
{
  NSMutableDictionary *props;
  NSString *str;
  NSArray *linearr;
  float strokeCol[4];
  float fillCol[4];
  float strokeAlpha;
  float fillAlpha;
  NSColor *color;
  id obj;

  props = [NSMutableDictionary dictionaryWithCapacity:2];

  [props setObject:[description objectForKey: @"posx"]  forKey:@"posx"];  
  [props setObject:[description objectForKey: @"posy"]  forKey:@"posy"];  
  [props setObject:[description objectForKey: @"height"]  forKey:@"height"];  
  [props setObject:[description objectForKey: @"width"]  forKey:@"width"];  

  str = [description objectForKey: @"strokecolor"];
  linearr = [str componentsSeparatedByString: @" "];
  strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];
  color = nil;
  if ([linearr count] == 3)
    {
      strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
      strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
      strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
      color = [NSColor colorWithCalibratedRed: strokeCol[0]
					green: strokeCol[1]
					 blue: strokeCol[2]
					alpha: strokeAlpha];
    }
  else
    {
      strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
      strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
      strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
      strokeCol[3] = [[linearr objectAtIndex: 3] floatValue];
      color = [NSColor colorWithDeviceCyan: strokeCol[0]
				   magenta: strokeCol[1]
				    yellow: strokeCol[2]
				     black: strokeCol[3]
				     alpha: strokeAlpha];
      color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    }
  if (color)
    [props setObject:color forKey:@"strokecolor"];

  str = [description objectForKey: @"fillcolor"];
  linearr = [str componentsSeparatedByString: @" "];
  fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];
  color = nil;
  if ([linearr count] == 3)
    {
      fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
      fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
      fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
      color = [NSColor colorWithCalibratedRed: fillCol[0]
					    green: fillCol[1]
					     blue: fillCol[2]
					    alpha: fillAlpha];
    }
  else
    {
      fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
      fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
      fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
      fillCol[3] = [[linearr objectAtIndex: 3] floatValue];
      color = [NSColor colorWithDeviceCyan: fillCol[0]
				   magenta: fillCol[1]
				    yellow: fillCol[2]
				     black: fillCol[3]
				     alpha: fillAlpha];
      color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    }
  if (color)
    [props setObject:color forKey:@"fillcolor"];
  
  obj = [description objectForKey: @"stroked"];
  if ([obj isKindOfClass:[NSString class]])
    obj = [NSNumber numberWithInt:[obj intValue]];
  [props setObject:obj forKey:@"stroked"];

  obj = [description objectForKey: @"filled"];
  if ([obj isKindOfClass:[NSString class]])
    obj = [NSNumber numberWithInt:[obj intValue]];	
  [props setObject:obj forKey:@"filled"];

  obj = [description objectForKey: @"visible"];
  if ([obj isKindOfClass:[NSString class]])
    obj = [NSNumber numberWithInt:[obj intValue]];	
  [props setObject:obj forKey:@"visibile"];
  
  obj = [description objectForKey: @"locked"];
  if ([obj isKindOfClass:[NSString class]])
    obj = [NSNumber numberWithInt:[obj intValue]];
  [props setObject:obj forKey:@"locked"];

  obj = [description objectForKey: @"rotation"];
  if (obj)
    [props setObject:obj forKey: @"rotation"];

  [props setObject:[description objectForKey: @"flatness"] forKey: @"flatness"];
  [props setObject:[description objectForKey: @"linejoin"] forKey: @"linejoin"];
  [props setObject:[description objectForKey: @"linecap"] forKey: @"linecap"];
  [props setObject:[description objectForKey: @"miterlimit"] forKey: @"miterlimit"];
  [props setObject:[description objectForKey: @"linewidth"] forKey: @"linewidth"];

  obj = [description objectForKey: @"imgrepdata"];
  if (obj)
    [props setObject:obj forKey: @"imgrepdata"];
  
  self = [self initInView:aView zoomFactor:zf withProperties:props];
  if(self)
    {
	NSLog(@"initInView description of GRImage");
    }
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  GRImage *objCopy;
  
  objCopy = [super copyWithZone:zone];
  
  objCopy->image = [image copy];
  objCopy->name = [name copy];
  
  return objCopy;
}

- (void)dealloc
{
  [image release];
  [name release];
  [super dealloc];
}

- (NSDictionary *)objectDescription
{
  NSMutableDictionary *dict;
  NSData *imgData;

  dict = (NSMutableDictionary *)[super objectDescription]; /* we know the superclass actually returns a mutable dict */
  [dict retain];
  
  [dict setObject: @"image" forKey: @"type"];

  imgData = [image TIFFRepresentation];
  
  [dict setObject:imgData forKey:@"imgrepdata"];
  [dict autorelease];
  return dict;
}

/** draws the object and calls the editor to draw itself afterwards */
- (void)draw
{
  NSBezierPath *bzp;
  CGFloat linew;

  linew = linewidth * zmFactor;
  
  bzp = [NSBezierPath bezierPath];
  [bzp appendBezierPathWithRect:boundsZ];
  if(filled)
    {
      [NSGraphicsContext saveGraphicsState];
      [fillColor set];
      [bzp fill];
      [NSGraphicsContext restoreGraphicsState];
    }
  
  [image drawInRect:boundsZ fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
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

- (NSImage *)image
{
  return image;
}

- (void)setImage:(NSImage *)img
{
  if (img != image)
    {
      [img retain];
      [image release];
      image = img;
      [image retain];
      originalSize = [image size];
      originalRatio = originalSize.width / originalSize.height;
    }
}

- (float)originalRatio
{
  return originalRatio;
}

@end
