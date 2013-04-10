/*
   Project: OresmeKit

   Copyright (C) 2011-2013 Free Software Foundation

   Author: multix

   Created: 2011-09-08 15:09:20 +0200 by multix

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
#import <AppKit/NSBezierPath.h>

#import "OKLineChart.h"
#import "OKSeries.h"

@implementation OKLineChart

-(id)initWithFrame: (NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  if (self)
    {
      minXUnitSize = 10;
      minYUnitSize = 10;
      NSLog (@"minimum sizes inited");
    }
  return self;
}



-(void)drawRect: (NSRect)rect
{
  NSBezierPath *path;
  NSRect boundsRect;
  unsigned i, j;
  float oneXUnit;
  float oneYUnit;
  float xUnitSize;
  float yUnitSize;
  float availableHeight;
  float availableWidth;
  float rangeToRepresent;
  float axisLevel;
  float minXPos;
  float minYPos;
  unsigned steps;

  /* bottom and left limits of the graph */
  minXPos = 10;
  minYPos = 10;
  
  /* the super method will have calculated the limits */
  [super drawRect: rect];
  boundsRect = [self bounds];
  availableHeight = boundsRect.size.height * 0.9;
  availableWidth = boundsRect.size.width * 0.9;
  rangeToRepresent = graphMaxYVal - graphMinYVal;
  if (rangeToRepresent == 0)
    {
      NSLog(@"No Y range to represent");
      return;
    }
  oneYUnit = availableHeight / rangeToRepresent;
  oneXUnit = availableWidth / graphMaxXVal;
  axisLevel = minYPos;
  if (graphMinYVal < 0)
    axisLevel += round(-oneYUnit * graphMinYVal);
  NSLog(@"x-y unit: %f, %f:, axisLevel: %f", oneXUnit, oneYUnit, axisLevel);
  xUnitSize = oneXUnit;
  if (xUnitSize < minXUnitSize)
    {
    while (xUnitSize < minXUnitSize)
      xUnitSize += oneXUnit;
    }
  else
    xUnitSize = oneXUnit;
  
  yUnitSize = oneYUnit;
  if (yUnitSize < minYUnitSize)
    {
    while (yUnitSize < minYUnitSize)
      yUnitSize += oneYUnit;
    }
  else
    yUnitSize = oneYUnit;
  
  NSLog(@"unit sizes: %f, %f", xUnitSize, yUnitSize);
  
  
  /* draw grid */
  if (gridStyle != OKGridNone)
    {
      [gridColor set];
      if (gridStyle == OKGridHorizontal || gridStyle == OKGridBoth)
        {
          steps = availableHeight / yUnitSize;
          NSLog(@"y steps: %u", steps);
          for (i = 0; i < steps; i++)
            {
              float y;
          
              y = round(minYPos + i * yUnitSize);
              [NSBezierPath strokeRect: NSMakeRect(minXPos, y, boundsRect.size.width, 0)];
            }
          }
      if (gridStyle == OKGridVertical || gridStyle == OKGridBoth)
        {
        steps =  availableWidth / xUnitSize;
        NSLog(@"x steps: %u", steps);
        for (i = 0; i < steps; i++)
          {
            float x;
        
            x = round(minXPos + i * xUnitSize);
            [NSBezierPath strokeRect: NSMakeRect(x, minYPos, 0, boundsRect.size.height)];
          }
        steps = availableHeight / yUnitSize;
        }
    }
  
  /* draw axes */
  [axisColor set];
  path = [[NSBezierPath alloc] init];
  [path setLineWidth:1.0];
  [path moveToPoint: NSMakePoint(minXPos, axisLevel)];
  [path lineToPoint: NSMakePoint(boundsRect.size.width, axisLevel)];
  [path moveToPoint: NSMakePoint(minXPos, minYPos)];
  [path lineToPoint: NSMakePoint(minXPos, boundsRect.size.height)];
  [path stroke];  
  [path release];
  //[NSBezierPath strokeRect: NSMakeRect(minXPos, axisLevel, boundsRect.size.width, 0)];
  //[NSBezierPath strokeRect: NSMakeRect(minXPos, minYPos, 0, boundsRect.size.height)];

  /* draw units */
  steps =  availableWidth / xUnitSize;
  NSLog(@"x steps: %u", steps);
  for (i = 0; i < steps; i++)
    {
      float x;

      x = minXPos + i * xUnitSize;
      [NSBezierPath strokeRect: NSMakeRect(x, axisLevel-1, 0, 2)];
    }
  steps = availableHeight / yUnitSize;
  NSLog(@"y steps: %u", steps);
  for (i = 0; i < steps; i++)
    {
      float y;

      y = minYPos + i * yUnitSize;
      [NSBezierPath strokeRect: NSMakeRect(minXPos, y, 2, 0)];
    }
  NSLog(@"top is: %f", i * (yUnitSize / oneYUnit));
  
  /* draw graph */
  for (i = 0; i < [seriesArray count]; i++)
    {
      OKSeries *series;
      float x;
      float y;
      NSPoint p;

      series = [seriesArray objectAtIndex: i];
      if ([series count] > 0)
	{
	  path = [[NSBezierPath alloc] init];
	  [[series color] set];
	  x = minXPos;
	  y = axisLevel + [[series objectAtIndex: 0] floatValue] * oneYUnit;
	  p = NSMakePoint(x, y);
	  [path moveToPoint: p];
	  x += oneXUnit;
	  for (j = 1; j < [series count]; j++)
	    {
	      y = axisLevel + [[series objectAtIndex: j] floatValue] * oneYUnit;
	      p = NSMakePoint(x, y);
	      [path lineToPoint: p];
	      x += oneXUnit;
	    }
	  [path stroke];
	  [path release];
	}
    }
}


@end
