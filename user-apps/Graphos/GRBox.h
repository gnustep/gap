/*
 Project: Graphos
 GRBox.h

 Copyright (C) 2007-2008 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2007-09-21

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
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#import <Foundation/Foundation.h>
#import <AppKit/NSBezierPath.h>
#import "GRDrawableObject.h"
#import "GRObjectControlPoint.h"

@interface GRBox : GRDrawableObject
{
    NSBezierPath *myPath;
    NSPoint pos;
    NSSize size;
    NSRect bounds;
    GRObjectControlPoint *startControlPoint;
    GRObjectControlPoint *endControlPoint;
    float rotation;
    float strokeColor[4], fillColor[4];
    float strokeAlpha, fillAlpha;
    float flatness, miterlimit, linewidth;
    float scalex, scaley;
    int linejoin, linecap;
    BOOL stroked, filled;
}

- (id)initInView:(GRDocView *)aView
      zoomFactor:(float)zf;



@end
