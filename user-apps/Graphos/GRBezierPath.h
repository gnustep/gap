/*
 Project: Graphos
 GRBezierPath.h

 Copyright (C) 2000-2008 GNUstep Application Project

 Author: Enrico Sersale (original implementation)
 Author: Ing. Riccardo Mottola

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
#import <AppKit/AppKit.h>
#import "GRPathObject.h"
#import "GRBezierControlPoint.h"


typedef struct
{
    GRBezierControlPoint *cp;
    NSPoint p;
    double t;
} hitData;

@interface GRBezierPath : GRPathObject
{
    NSBezierPath *myPath;
    float strokeColor[4], fillColor[4];
    float strokeAlpha, fillAlpha;
    float flatness, miterlimit, linewidth;
    int linejoin, linecap;
    BOOL calculatingHandles;
    NSMutableArray *controlPoints;
}

- (id)initInView:(GRDocView *)aView zoomFactor:(float)zf;

- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(float)zf;


- (void)addControlAtPoint:(NSPoint)aPoint;
- (void)addLineToPoint:(NSPoint)aPoint;
- (void)addCurveWithBezierHandlePosition:(NSPoint)handlePos;

- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split;

- (NSMutableArray *)controlPoints;
- (BOOL)isPoint:(GRBezierControlPoint *)cp1 onPoint:(GRBezierControlPoint *)cp2;
- (GRBezierControlPoint *)pointOnPoint:(GRBezierControlPoint *)aPoint;
- (void)confirmNewCurve;

- (void)setFlat:(float)flat;
- (float)flatness;
- (void)setLineJoin:(int)join;
- (int)lineJoin;
- (void)setLineCap:(int)cap;
- (int)lineCap;
- (void)setMiterLimit:(float)limit;
- (float)miterLimit;
- (void)setLineWidth:(float)width;
- (float)lineWidth;

- (void)setStrokeColor:(float *)c;
- (float *)strokeColor;
- (void)setStrokeAlpha:(float)alpha;
- (float)strokeAlpha;
- (void)setFillColor:(float *)c;
- (float *)fillColor;
- (void)setFillAlpha:(float)alpha;
- (float)fillAlpha;

- (void)unselectOtherControls:(GRBezierControlPoint *)cp;


- (void)remakePath;

- (hitData)hitDataOfPathSegmentOwningPoint:(NSPoint)pt;

- (void)moveAddingCoordsOfPoint:(NSPoint)p;

- (void)setZoomFactor:(float)f;

- (BOOL)onPathBorder:(NSPoint)p;

- (GRBezierControlPoint *)firstPoint;
- (GRBezierControlPoint *)lastPoint;

- (int)indexOfPoint:(GRBezierControlPoint *)aPoint;


@end

