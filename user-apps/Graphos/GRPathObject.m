/*
 Project: Graphos
 GRPathObject.m
 
 Copyright (C) 2008-2013 GNUstep Application Project
 
 Author: Ing. Riccardo Mottola
 
 Created: 2008-03-14
 
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
#import "GRPathObject.h"


@implementation GRPathObject

- (id)copyWithZone:(NSZone *)zone
{
  GRPathObject *objCopy;
  NSBezierPath *bzpCopy;
  
  bzpCopy = [myPath copy];
  
  objCopy = [super copyWithZone:zone];
  objCopy->myPath = bzpCopy;
  objCopy->linewidth = linewidth;
  objCopy->flatness = flatness;
  objCopy->miterlimit = miterlimit;
  objCopy->linejoin = linejoin;
  objCopy->linecap = linecap;
  [objCopy setCurrentPoint:[self currentPoint]];
  
  return objCopy;
}

- (void)dealloc
{
  [myPath release];
  [super dealloc];
}

- (id)initInView:(GRDocView *)aView
      zoomFactor:(CGFloat)zf
      withProperties:(NSDictionary *)properties
{
  self = [super initInView:aView zoomFactor:zf withProperties:properties];
  if(self)
    {
      id val;

      myPath = [[NSBezierPath bezierPath] retain];
      [myPath setCachesBezierPath: NO];

      flatness = 0.0;
      miterlimit = 2.0;
      linewidth = 1.5;
      linejoin = 0;
      linecap = 0;

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
    }
  return self;
}

- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(CGFloat)zf
{
  self = [super init];
  if(self)
    {
      NSLog(@"initInView description of GRPathObject");
    }
  return self;
}

- (void)setCurrentPoint:(GRObjectControlPoint *)aPoint
{
    currentPoint = aPoint;
}

- (GRObjectControlPoint *)currentPoint
{
    return currentPoint;
}

- (void)setLineWidth:(CGFloat)width
{
  linewidth = width;
}

- (CGFloat)lineWidth
{
  return linewidth;
}

- (void)setFlat:(CGFloat)flat
{
  flatness = flat;
}

- (CGFloat)flatness
{
  return flatness;
}

- (void)setLineJoin:(NSLineJoinStyle)join
{
  linejoin = join;
}

- (NSLineJoinStyle)lineJoin
{
  return linejoin;
}

- (void)setLineCap:(NSLineCapStyle)cap
{
  linecap = cap;
}

- (NSLineCapStyle)lineCap
{
  return linecap;
}

- (void)setMiterLimit:(CGFloat)limit
{
  miterlimit = limit;
}

- (CGFloat)miterLimit
{
  return miterlimit;
}

- (void)remakePath
{
}

@end
