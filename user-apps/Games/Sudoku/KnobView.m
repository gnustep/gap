/* 
   Project: Sudoku
   KnobView.m

   Copyright (C) 2007-2011 The Free Software Foundation, Inc

   Author: Marko Riedel

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import "KnobView.h"

@implementation KnobView


- (float)percent
{
    return percent;
}

- setPercent:(float)pval
{
    NSAssert(pval>=0.0 && pval<=100.0, @"not a percentage");
    percent = pval;
    return self;
}

- (void)drawRect:(NSRect)aRect
{
    NSRect frame = [self frame];
    float radius = frame.size.height/3.0;
    NSPoint center = {
        percent*frame.size.width/100.0, frame.size.height/2.0
    };
    
    [[NSColor whiteColor] set];
    PSrectfill(0, 0, frame.size.width, frame.size.height);

    [[NSColor blueColor] set];
    if(center.x<radius){
        center.x = radius;
    }
    else if(center.x>frame.size.width-radius){
        center.x = frame.size.width-radius;
    }
    PSarc(center.x, center.y, radius, 0, 360);
    PSfill();

    [[NSColor  blackColor] set];
    PSsetlinewidth(4);
    PSrectstroke(0, 0, frame.size.width, frame.size.height);
}


@end
