/*
   Project: OresmeKit
   
   Chart: Generic chart superclass

   Copyright (C) 2011 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2011-09-08 12:14:11 +0200 by multix

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

#import "OKChart.h"
#import "OKSeries.h"

@implementation OKChart

-(id)initWithFrame: (NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  if (self)
    {
      backgroundColor = [[NSColor whiteColor] retain];
      axisColor = [[NSColor blackColor] retain];
      gridColor = [[NSColor grayColor] retain];
      gridStyle = OKGridBoth;
      seriesArray = [[NSMutableArray alloc] initWithCapacity: 1];
    }
  return self;
}

-(void)dealloc
{
  [seriesArray release];
  [backgroundColor release];
  [super dealloc];
}

-(void)drawRect: (NSRect)rect
{
  unsigned i, j;

  NSLog(@"OKChart Draw");

  /* search for min and max */
  /* since we want always to have the X axis, we start with 0, not the first value */
  graphMinYVal = 0;
  graphMaxYVal = 0;
  for (i = 0; i < [seriesArray count]; i++)
    {
      OKSeries *s;

      s = [seriesArray objectAtIndex: i];
      for (j = 0; j < [s count]; j++)
	{
	  float val;

	  val = [[s objectAtIndex: j] floatValue];
	  NSLog(@"val: %f", val);
	  if (val > graphMaxYVal)
	    graphMaxYVal = val;
	  if (val < graphMinYVal)
	    graphMinYVal = val;
	}
    }
  NSLog(@"graph Y limits: %f %f", graphMinYVal, graphMaxYVal);

  /* we look for the maximum count among all series */
  graphMaxXVal = 0;
  for (i = 0; i < [seriesArray count]; i++)
    {
      OKSeries *s;

      s = [seriesArray objectAtIndex: i];
      if ([s count] > graphMaxXVal)
	graphMaxXVal = [s count];
     }

  [backgroundColor set];
  [NSBezierPath fillRect: [self bounds]];
  
  NSLog(@"end super draw");
}

/** Sets the chart axis and lines color */
-(IBAction)setAxisColor:(NSColor *)color
{
  [axisColor release];
  axisColor = [color retain];
}

/** Sets the graph background color */
-(IBAction)setBackgroundColor:(NSColor *)color
{
  [backgroundColor release];
  backgroundColor = [color retain];
}

/** grid drawing style according to OKGridStyle */
- (IBAction)setGridStyle:(OKGridStyle)style
{
  gridStyle = style;
}

/** Set the grid color */
- (IBAction)setGridColor:(NSColor *)color
{
  [gridColor release];
  gridColor = [color retain];
}

/* returns the number of series arrays */
- (NSUInteger)seriesCount
{
  return [seriesArray count];
}

/** returns the series array identified by index */
- (OKSeries *)seriesAtIndex:(NSUInteger)index
{
  return [seriesArray objectAtIndex: index];
}

/** add the series */
- (void)addSeries: (OKSeries *)series
{
  [seriesArray addObject: series];
}

/** removes the series identified by index */
- (void)removeSeriesAtIndex: (NSUInteger)index
{
  [seriesArray removeObjectAtIndex: index];
}

/** removes all current series */
- (void)removeAllSeries
{
  [seriesArray removeAllObjects];
}

@end
