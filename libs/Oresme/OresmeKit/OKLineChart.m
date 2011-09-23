/*
   Project: OresmeKit

   Copyright (C) 2011 Free Software Foundation

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

-(void)drawRect: (NSRect)rect
{
  NSRect boundsRect;
  unsigned i, j;
  float oneUnit;
  float availableHeight;
  float rangeToRepresent;
  float axisLevel;

  [super drawRect: rect];
  boundsRect = [self bounds];
  availableHeight = boundsRect.size.height * 0.9;
  rangeToRepresent = graphMaxYVal - graphMinYVal;
  oneUnit = availableHeight / rangeToRepresent;

  axisLevel = 0;
  if (graphMinYVal < 0)
    axisLevel = -oneUnit * graphMinYVal;
  NSLog(@"unit: %f:, axisLevel; %f", oneUnit, axisLevel);
  [axisColor set];
  [NSBezierPath strokeRect: NSMakeRect(0, axisLevel, boundsRect.size.width, 0)];

  for (i = 0; i < [seriesArray count]; i++)
    {
      NSBezierPath *path;
      OKSeries *series;

      series = [seriesArray objectAtIndex: i];
      path = [[NSBezierPath alloc] init];
      [[series color] set];
      [path release];
    }
}


@end
