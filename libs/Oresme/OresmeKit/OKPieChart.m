/*
   Project: OresmeKit

   Copyright (C) 2012 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2012-10-25 23:01:18 +0200 by multix

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

#import "OKSeries.h"
#import "OKPieChart.h"

@implementation OKPieChart

-(void)drawRect: (NSRect)rect
{
  NSRect boundsRect;
  unsigned i, j;
  float availableHeight;
  float availableWidth;
  float radius;
  NSPoint center;
  NSMutableArray *valuesArray;
  NSMutableArray *colorsArray;
  double positiveSum;
  float currAngle;

  /* the super method will have calculated the limits */
  [super drawRect: rect];
  boundsRect = [self bounds];
  availableHeight = boundsRect.size.height * 0.9;
  availableWidth = boundsRect.size.width * 0.9;
  radius = availableWidth / 2;
  if (availableHeight < availableWidth)
    radius = availableHeight / 2;

  center = NSMakePoint(boundsRect.size.width / 2, boundsRect.size.height / 2);

  NSLog(@"draw Pie chart! radius: %f", radius);

  /* we scan all series to construct the an arrays of values by considering only positive values
     the respective color gets extracted and the total is calculated */
  positiveSum = 0;
  valuesArray = [[NSMutableArray alloc] initWithCapacity:[seriesArray count]];
  colorsArray = [[NSMutableArray alloc] initWithCapacity:[seriesArray count]];
  for (i = 0; i < [seriesArray count]; i++)
    {
      OKSeries *series;

      series = [seriesArray objectAtIndex: i];
      if ([series count] > 0)
	{
	  double v;

	  v = [[series objectAtIndex:0] doubleValue];
	  if (v > 0)
	    {
	      positiveSum += v;
	      [colorsArray addObject:[series color]];
	      [valuesArray addObject:[series objectAtIndex:0]];
	    }

	}
    }

  currAngle = 0;
  for (i = 0; i < [valuesArray count]; i++)
    {
      NSBezierPath *path;
      double v;
      float angle;


      path = [[NSBezierPath alloc] init];
      v = [[valuesArray objectAtIndex:i] doubleValue];

      /* alpha : 360 = value : total */
      angle = (v * 360.0) / positiveSum;

      [[colorsArray objectAtIndex:i] set];
      [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:currAngle endAngle:currAngle+angle];
      [path moveToPoint: center];
      [path lineToPoint: NSMakePoint(center.x + cos(currAngle*6.2831853/360)*radius, center.y + sin(currAngle*6.2831853/360)*radius)];

      [path moveToPoint: center];
      [path lineToPoint: NSMakePoint(center.x + cos((currAngle+angle)*6.2831853/360)*radius, center.y + sin((currAngle+angle)*6.2831853/360)*radius)];
      currAngle += angle;
      
      [path stroke];
      
      [path release];
    }
}

@end
