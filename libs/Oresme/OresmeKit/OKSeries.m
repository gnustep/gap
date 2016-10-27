/*
   Project: OresmeKit
   
   Numeric Series representation

   Copyright (C) 2011-2014 Free Software Foundation

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

#import "OKSeries.h"

@implementation OKSeries

-(id)init
{
  self = [super init];
  if (self)
    {
      description = @"No description";
      title = @"Untitled";
      color = [[NSColor blueColor] retain];
      highlighted = NO;
      seriesArray = [[NSMutableArray alloc] initWithCapacity: 1];
    }
  return self;
}

-(void)dealloc
{
  [description release];
  [title release];
  [color release];
  [seriesArray release];
  [super dealloc];
}

- (NSColor*)color
{
  return color;
}

-(void)setColor: (NSColor *)c
{
  if (color != c)
    {
      [color release];
      color = [c retain];
    }
}

- (BOOL)highlighted
{
  return highlighted;
}

- (void)setHighlighted: (BOOL)status
{
  highlighted = status;
}


- (NSString*)title
{
  return title;
}

- (void)setTitle: (NSString*)aTitle
{
  if (title != aTitle)
    {
      [title release];
      title = [aTitle retain];
    }
}

- (NSString*)description
{
  return description;
}

- (void)setDescription: (NSString*)aDescription
{
  if (description != aDescription)
    {
      [description release];
      description = [aDescription retain];
    }
}

/** calculate minimum and maximum value of the series */
- (void)calculateMinMax
{
  NSUInteger count;
  NSUInteger i;

  count = [seriesArray count];
  if (!count)
    {
      minValue = nil;
      maxValue = nil;
      return;
    }

  minValue = maxValue = [seriesArray objectAtIndex: 0];
  i = 1;
  while (i < count)
    {
      NSNumber *v;

      v = [seriesArray objectAtIndex:i];
      if ([maxValue compare: v] == NSOrderedAscending)
        maxValue = v;
      if ([minValue compare: v] == NSOrderedDescending)
        minValue = v;
      i++;
    }
}

/** smallest value in series */
- (NSNumber *)minValue
{
  return minValue;
}

/** largest value in series */
- (NSNumber *)maxValue
{
  return maxValue;
}


/* --- NSArray bridge methods ---*/

/** returns object at the specified index */
- (id) objectAtIndex: (NSUInteger)index
{
  return [seriesArray objectAtIndex: index];
}


/** adds object and updates of minimum and maximum value */
- (void) addObject: (id)obj
{
  [seriesArray addObject: obj];
  if ([seriesArray count] == 1)
    {
      maxValue = obj;
      minValue = obj;
    }
  else
    {
      if ([maxValue compare: obj] == NSOrderedAscending)
        maxValue = obj;
      if ([minValue compare: obj] == NSOrderedDescending)
        minValue = obj;
    }
}

/** number of elemens in Array */
- (NSUInteger) count
{
  return [seriesArray count]; 
}

/** removes all elements, leaving an empty series */
- (void) removeAllObjects
{
  [seriesArray removeAllObjects];
  [self calculateMinMax];
}

/** removes the element in series given by index */
- (void) removeObjectAtIndex: (NSUInteger)index
{
  [seriesArray removeObjectAtIndex: index];
  [self calculateMinMax];
}


/* --- end of NSArray bridge methods ---*/

@end
