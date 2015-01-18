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

#import <AppKit/AppKit.h>

@implementation GRImage


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
  
  [image drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
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

- (void)setImage:(NSImage *)img
{
  if (img != image)
    {
      [img retain];
      [image release];
      image = img;
      [image retain];
    }
}

@end
