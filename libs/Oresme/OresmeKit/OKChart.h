/*
   Project: OresmeKit
   
   Chart: Generic chart superclass

   Copyright (C) 2011-2013 Free Software Foundation

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
#import <AppKit/NSColor.h>
#import <AppKit/NSView.h>
#import <AppKit/NSNibDeclarations.h>


#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#define NSUInteger unsigned
#endif

typedef enum
{
  OKGridNone = 1,
  OKGridHorizontal,
  OKGridVertical,
  OKGridBoth
} OKGridStyle;

typedef enum
  {
    OKNumFmtPlain = 0,
    OKNumFmtKiloMega
  } OKNumberFormatting;

@class OKSeries;

@interface OKChart : NSView
{
  NSColor *backgroundColor;
  NSColor *axisColor;
  NSColor *gridColor;
  NSMutableArray *seriesArray;
  
  OKGridStyle gridStyle;

  float marginRight;
  float marginLeft;
  float marginTop;
  float marginBottom;

  float graphMinYVal;
  float graphMaxYVal;
  float graphMaxXVal;
}

+ (NSString *) format:(NSNumber *)number withFormat:(OKNumberFormatting) fmt;

- (IBAction)setAxisColor:(NSColor *)color;
- (IBAction)setBackgroundColor:(NSColor *)color;
- (IBAction)setGridStyle:(OKGridStyle)style;
- (IBAction)setGridColor:(NSColor *)color;
- (NSUInteger)seriesCount;
- (OKSeries *)seriesAtIndex:(NSUInteger)index;
- (void)addSeries: (OKSeries *)series;
- (void)removeSeriesAtIndex: (NSUInteger)index;
- (void)removeAllSeries;

@end


