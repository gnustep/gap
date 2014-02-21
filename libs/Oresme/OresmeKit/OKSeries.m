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

/* --- NSArray bridge methods ---*/

- (id) objectAtIndex: (NSUInteger)index
{
  return [seriesArray objectAtIndex: index];
}

- (void) addObject: (id)obj
{
  [seriesArray addObject: obj];
}

- (NSUInteger) count
{
  return [seriesArray count]; 
}
- (void) removeAllObjects
{
  [seriesArray removeAllObjects];
}

- (void) removeObjectAtIndex: (NSUInteger)index
{
  [seriesArray removeObjectAtIndex: index];
}


/* --- end of NSArray bridge methods ---*/

@end
