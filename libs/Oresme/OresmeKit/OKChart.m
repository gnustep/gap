/*
   Project: OresmeKit
   
   Chart: Generic chart superclass

   Copyright (C) 2011-2014 Free Software Foundation

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


/** considering the input string as a floating point number, remove the trailing zeroes
    if is a non-integer number.
    This method should never be called with a number containing thousands separators but no decimal separator */
+ (NSString *)purgeTrailingZeroes:(NSString *)s
{
  NSString *str;
  NSRange rangeOfLastDot;
  NSRange rangeOfLastComma;
  NSUInteger decimalLocation;

  rangeOfLastDot = [s rangeOfString:@"." options:NSBackwardsSearch];
  rangeOfLastComma = [s rangeOfString:@"," options:NSBackwardsSearch];
  decimalLocation = NSNotFound;
 
  /* we have nothing to do */
  if (rangeOfLastDot.length == 0 && rangeOfLastComma.length == 0)
    return s;

  /* we suppose a dot as decimalSeparator */
  if (rangeOfLastDot.location != NSNotFound  && (rangeOfLastDot.location > rangeOfLastComma.location || rangeOfLastComma.location == NSNotFound))
    {
      decimalLocation = rangeOfLastDot.location;
    }
  /* we suppose a comma as decimalSeparator */
  else if (rangeOfLastComma.location != NSNotFound && (rangeOfLastComma.location > rangeOfLastDot.location || rangeOfLastDot.location ==NSNotFound))
    {
      decimalLocation = rangeOfLastComma.location;
    }

  str = s;
  if (decimalLocation != NSNotFound)
    {
      while ([str characterAtIndex:([str length]-1)] == '0')
        str = [str substringWithRange:NSMakeRange(0, [str length]-1)];

      /* we removed all trailing zeroes up to the decimal separator */
      if([str length]-1 == decimalLocation)
        str = [str substringWithRange:NSMakeRange(0, [str length]-1)];
    }
  return str;
}

+ (NSString *) format:(NSNumber *)number withFormat:(OKNumberFormatting) fmt
{
  NSString *strRes;
  
  strRes = nil;
  
  if (fmt == OKNumFmtPlain)
    {
      strRes = [NSString localizedStringWithFormat:@"%.3lf", (double)[number doubleValue]];
      strRes = [OKChart purgeTrailingZeroes:strRes];
    }
  else if (fmt == OKNumFmtKiloMega)
    {
      double d;
      int c;
      NSString *s;

      d = [number doubleValue];
      c = 0;
      if (abs(d) > 1000)
        {
          while (abs(d) > 1000)
            {
              d /= 1000;
              c++;
            }
        }
      else if ((abs(d) > 0) && (abs(d) < 1))
        {
          while (abs(d) < 0.001)
            {
              d *= 1000;
              c--;
            }
        }
      NSLog(@"residual: %lf, %d", d, c);
      s = [NSString stringWithFormat:@"%.3lf", (double)[number doubleValue]];
      s = [OKChart purgeTrailingZeroes:s];
      if (c == -3)
        s = [s stringByAppendingString:@"p"];
      else if (c  == -2)
        s = [s stringByAppendingString:@"u"];
      else if (c == -1)
        s = [s stringByAppendingString:@"m"];
      else if (c == 1)
        s = [s stringByAppendingString:@"K"];
      else if (c == 2)
        s = [s stringByAppendingString:@"M"];
      else if (c == 3)
        s = [s stringByAppendingString:@"G"];
      else if (c == 3)
        s = [s stringByAppendingString:@"T"];
      else if (c != 0)
        NSLog(@"Number %@ too big or too small", number);

      return s;
    }
  
  return strRes;
}

-(id)initWithFrame: (NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  if (self)
    {
      backgroundColor = [[NSColor whiteColor] retain];
      axisColor = [[NSColor blackColor] retain];
      gridColor = [[NSColor lightGrayColor] retain];
      gridStyle = OKGridBoth;
      xAxisLabelStyle = OKGridNone;
      yAxisLabelStyle = OKGridNone;
      xAxisGridSizing = OKGridConstantSize;
      yAxisGridSizing = OKGridConstantSize;
      yLabelNumberFmt = OKNumFmtPlain;
      seriesArray = [[NSMutableArray alloc] initWithCapacity: 1];
      marginRight = 5;
      marginLeft = 5;
      marginTop = 5;
      marginBottom = 5;
      xAxisGridValues = [[NSMutableArray alloc] initWithCapacity: 1];
      yAxisGridValues = [[NSMutableArray alloc] initWithCapacity: 1];
    }
  return self;
}

-(void)dealloc
{
  [seriesArray release];
  [backgroundColor release];
  [axisColor release];
  [gridColor release];
  [xAxisGridValues release];
  [yAxisGridValues release];
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
          //	  NSLog(@"val: %f", val);
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

/** set left margin */
- (void)setMarginLeft:(float)margin
{
  marginLeft = margin;
}

/** set right margin */
- (void)setMarginRight:(float)margin
{
  marginRight = margin;
}

/** set bottom margin */
- (void)setMarginBottom:(float)margin
{
  marginBottom = margin;
}

/** set Top margin */
- (void)setMarginTop:(float)margin
{
  marginTop = margin;
}

/** sets if and how axis labels are drawn */
- (void)setxAxisLabelStyle:(OKLabelStyle)style
{
  xAxisLabelStyle = style;
}

/** sets if and how axis labels are drawn */
- (void)setyAxisLabelStyle:(OKLabelStyle)style
{
  yAxisLabelStyle = style;
}

/** set label number formatting */
- (void)setYLabelNumberFormatting:(OKNumberFormatting)fmt
{
  yLabelNumberFmt = fmt;
}

/** set gid sizing */
- (void)setXAxisGridSizing:(OKGridSizing)sizing
{
  xAxisGridSizing = sizing;
}

/** set gid sizing */
- (void)setYAxisGridSizing:(OKGridSizing)sizing
{
  yAxisGridSizing = sizing;
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
