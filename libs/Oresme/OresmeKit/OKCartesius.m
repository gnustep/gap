/*
   Project: OresmeKit
   
   Carthesius: Abscissa/Ordinata Charts

   Copyright (C) 2011 Free Software Foundation

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
#import <AppKit/AppKit.h>

#import "OKCartesius.h"

@implementation OKCartesius

-(id)initWithFrame: (NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  if (self)
    {
      quadrantPositioning = OKQuadrantCentered;
      arrayX = [[NSMutableArray alloc] initWithCapacity: 10];
      arrayY = [[NSMutableArray alloc] initWithCapacity: 10];
    }
  return self;
}

-(void)drawRect: (NSRect)rect
{
  NSPoint origo;
  NSRect boundsRect;
  NSBezierPath *path;
  int i;
  
  NSLog(@"Draw");
  origo = NSMakePoint(0, 0);
  boundsRect = [self bounds];
  if (quadrantPositioning == OKQuadrantCentered)
    {
      origo = NSMakePoint(boundsRect.size.width/2, boundsRect.size.height/2);
    }
    
  [[NSColor whiteColor] set];
  [NSBezierPath fillRect: [self bounds]];
  
  [[NSColor blackColor] set];
  [NSBezierPath strokeRect: NSMakeRect(0, origo.y, boundsRect.size.width, origo.y)];
  [NSBezierPath strokeRect: NSMakeRect(origo.x, 0, origo.x, boundsRect.size.height)];


}

-(void)dealloc
{
  [arrayX release];
  [arrayY release];
  [super dealloc];
}

-(NSMutableArray *)arrayX
{
  return arrayX;
}

-(NSMutableArray *)arrayY
{
  return arrayY;
}

@end
