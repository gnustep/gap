/*
 Project: Graphos
 GRPathObject.m
 
 Copyright (C) 2008-2010 GNUstep Application Project
 
 Author: Ing. Riccardo Mottola
 
 Created: 2008-03-14
 
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
#import "GRPathObject.h"


@implementation GRPathObject

- (id)copyWithZone:(NSZone *)zone
{
    GRPathObject *objCopy;
    NSBezierPath *bzpCopy;

    bzpCopy = [myPath copy];
    
    objCopy = [super copyWithZone:zone];
    objCopy->myPath = bzpCopy;
    [objCopy setCurrentPoint:[self currentPoint]];
    
    return objCopy;
}

- (void)dealloc
{
    [myPath release];
    [super dealloc];
}

- (void)setFilled:(BOOL)value
{
    filled = value;
}

- (BOOL)isFilled
{
    return filled;
}

- (void)setStroked:(BOOL)value
{
    stroked = value;
}

- (BOOL)isStroked
{
    return stroked;
}
- (void)setCurrentPoint:(GRObjectControlPoint *)aPoint
{
    currentPoint = aPoint;
}

- (GRObjectControlPoint *)currentPoint
{
    return currentPoint;
}

- (void)remakePath
{
}

@end
