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
  [axisColor set];
  NSBezierPath *path;
  path = [[NSBezierPath alloc] init];

  [path appendBezierPathWithArcWithCenter:center radius:radius startAngle:0 endAngle:360];

  [path stroke];

  [path release];
}

@end
