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
#import <AppKit/NSColor.h>
#import <AppKit/NSBezierPath.h>

#import "OKChart.h"

@implementation OKChart

-(id)initWithFrame: (NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  if (self)
    {
      backgroundColor = [[NSColor whiteColor] retain];
    }
  return self;
}

-(void)drawRect: (NSRect)rect
{
  NSRect boundsRect;
  
  NSLog(@"OKChart Draw");

  [backgroundColor set];
  [NSBezierPath fillRect: [self bounds]];
  
  boundsRect = [self bounds];
}

-(void)setBackgroundColor:(NSColor *)color
{
  [backgroundColor release];
  backgroundColor = [color retain];
}

@end
