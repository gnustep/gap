/*
   Project: OresmeKit
   
   Carthesius: Abscissa/Ordinata Charts

   Copyright (C) 2011 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2011-08-21 23:58:53 +0200 by multix

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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "OKCartesius.h"

@implementation OKCartesius

-(id)initWithFrame: (NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  if (self)
    {
      quadrantPositioning = OKQuadrantCentered;
      arrayX = [[NSMutableArray alloc] initWithCapacity: 10];
      arrayY = [[NSMutableArray alloc] initWithCapacity: 10];
      backgroundColor = [[NSColor whiteColor] retain];
      axisColor = [[NSColor blackColor] retain];
      curveColor = [[NSColor blueColor] retain];
      visibleXUnits = 10;
      visibleYUnits = 10;
    }
  return self;
}

-(void)drawRect: (NSRect)rect
{
  NSPoint origo;
  NSRect boundsRect;
  NSBezierPath *path;
  int i;
  NSPoint p;
  float xScale, yScale;
  float hugeVal;
  
  NSLog(@"Draw");

  [backgroundColor set];
  [NSBezierPath fillRect: [self bounds]];

  if ([arrayX count] == 0)
    {
      NSLog(@"nothing to draw");
      return;
    }

  if ([arrayX count] != [arrayY count])
    {
      NSLog(@"X-Y series array differ insize, incoherency detected.");
      return;
    }

  boundsRect = [self bounds];
  xScale = boundsRect.size.width / visibleXUnits;
  yScale = boundsRect.size.height / visibleYUnits;
  hugeVal = boundsRect.size.width * 100;

  origo = NSMakePoint(0, 0);
  if (quadrantPositioning == OKQuadrantCentered)
    {
      origo = NSMakePoint(boundsRect.size.width/2, boundsRect.size.height/2);
    }
  else if (quadrantPositioning == OKQuadrantI)
    {
      origo = NSMakePoint(0,0);
    }
  else if (quadrantPositioning == OKQuadrantII)
    {
      origo = NSMakePoint(boundsRect.size.width, 0);
    }
  else if (quadrantPositioning == OKQuadrantIII)
    {
      origo = NSMakePoint(boundsRect.size.width, boundsRect.size.height);
    }
  else if (quadrantPositioning == OKQuadrantIV)
    {
      origo = NSMakePoint(0, boundsRect.size.height);
    }
 
  [axisColor set];
  [NSBezierPath strokeRect: NSMakeRect(0, origo.y, boundsRect.size.width, origo.y)];
  [NSBezierPath strokeRect: NSMakeRect(origo.x, 0, origo.x, boundsRect.size.height)];

  [curveColor set];
  path = [[NSBezierPath alloc] init];

  i = 0;
  p = NSMakePoint([[arrayX objectAtIndex: i] floatValue] * xScale + origo.x,
		  [[arrayY objectAtIndex: i] floatValue] * yScale + origo.y
		  );
  [path moveToPoint: p];
  i++;
  while (i < [arrayX count])
    {
      p = NSMakePoint([[arrayX objectAtIndex: i] floatValue] * xScale + origo.x,
		      [[arrayY objectAtIndex: i] floatValue] * yScale + origo.y
		      );
      if (isnan(p.x))
	{
	  if (p.x > 0)
	    p.x = hugeVal;
	  else
	    p.x = -hugeVal;
	}
      if (isnan(p.y))
	{
	  if (p.y > 0)
	    p.y = hugeVal;
	  else
	    p.y = -hugeVal;
	}
      NSLog(@"%f %f", p.x, p.y);
      [path lineToPoint: p];
      i++;
    }
  [path stroke];

  [path release];
}

-(void)dealloc
{
  [arrayX release];
  [arrayY release];
  [backgroundColor release];
  [super dealloc];
}

-(NSMutableArray *)arrayX
{
  return arrayX;
}

-(NSMutableArray *)arrayY
{
  return arrayY;
}

-(void)setVisibleXUnits: (float)units
{
  visibleXUnits = units;
}

-(void)setVisibleYUnits: (float)units
{
  visibleYUnits = units;
}


-(void)setQuadrantPositioning:(OKQuadrantPositioning)p
{
  quadrantPositioning = p;
}

-(void)setBackgroundColor:(NSColor *)color
{
  [backgroundColor release];
  backgroundColor = [color retain];
}

-(void)setAxisColor:(NSColor *)color
{
  [axisColor release];
  axisColor = [color retain];
}

-(void)setCurveColor:(NSColor *)color
{
  [curveColor release];
  curveColor = [color retain];
}

@end
