/*
   Project: OresmeKit
   
   Numeric Series representation

   Copyright (C) 2011-2015 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2011-09-08 12:16:05 +0200 by multix

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

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#define NSUInteger unsigned
#endif

/**
   <p>OKseries provides the series data storage used by charts.</p>
   <p>A series contains an array of scalar data (NSNumbers) and additional information like color, description and title</p>
 */
@interface OKSeries : NSObject
{
  NSString       *description;
  NSString       *title;

  /** Series color, used when drawing the chart. E.g. the line color or the pie sector */
  NSColor        *color;

  /** if the series should be highlighted compared to others, e.g. drawin in bold or brighter colour */
  BOOL highlighted;

  /** Array containing series data */
  NSMutableArray *seriesArray;

  /** minimum value, kept updated while adding/removing */
  NSNumber *minValue;
  /** maximum value, kept updated while adding/removing */
  NSNumber *maxValue;
}

- (NSColor*) color;
- (void) setColor: (NSColor *)c;
- (BOOL)highlighted;
- (void)setHighlighted: (BOOL)status;
- (NSString*) title;
- (void) setTitle:(NSString*)aTitle;
- (NSString*) description;
- (void) setDescription:(NSString*)aDescription;

- (NSNumber *)minValue;
- (NSNumber *)maxValue;

- (id) objectAtIndex: (NSUInteger)index;
- (void) addObject: (id)obj;
- (NSUInteger) count;
- (void) removeAllObjects;
- (void) removeObjectAtIndex: (NSUInteger)index;

@end


