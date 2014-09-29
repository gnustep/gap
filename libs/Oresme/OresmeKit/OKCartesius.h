/*
   Project: OresmeKit

   Copyright (C) 2011-2014 Free Software Foundation

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
#import <AppKit/NSView.h>

/** Defines the quadrants plotted. */
typedef enum
  {
    /** All quadrants visible, origin is placed in the middle */
    OKQuadrantCentered = 0,

    /** Quadrant I */
    OKQuadrantI = 1,

    /** Quadrant II */
    OKQuadrantII = 2,

    /** Quadrant III */
    OKQuadrantIII = 3,

    /** Quadrant IV */
    OKQuadrantIV = 4,

    /** Automatic placement. E.g. Quadrant 3 and 4 are not visible, only y-positive values are displayed */
    OKQuadrantAuto = 5
  } OKQuadrantPositioning;


/**
   <p>The OKCartesius class is meant to plot x-y data, e.g. like a y=f(x) function on a Carthesian plane.
   </p>
   <p>Data is represented as an array of NSPoints.
   </p>
   <p>The engine can plot one or two curves in different colors on the same plane with the same scale.
   </p>
 */
@interface OKCartesius : NSView
{
  OKQuadrantPositioning quadrantPositioning;
  NSMutableArray *curve1; /** array of NSPoints in NSValues */
  NSMutableArray *curve2; /** array of NSPoints in NSValues */
  NSColor *backgroundColor;
  NSColor *axisColor;
  NSColor *curve1Color;
  NSColor *curve2Color;
  float visibleXUnits;
  float visibleYUnits;
}

-(NSMutableArray *)curve1;
-(NSMutableArray *)curve2;

-(void)setVisibleXUnits: (float)units;
-(void)setVisibleYUnits: (float)units;
-(void)setQuadrantPositioning:(OKQuadrantPositioning)p;
-(void)setBackgroundColor:(NSColor *)color;
-(void)setAxisColor:(NSColor *)color;
-(void)setCurve1Color:(NSColor *)color;
-(void)setCurve2Color:(NSColor *)color;

@end


