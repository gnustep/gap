//
//  GRBezierPath.h
//  Graphos
//
//  Created by Riccardo Mottola on Sat Feb 23 2008.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRBezierControlPoint.h"

@class GRBezierPathEditor;

typedef struct {
    GRBezierControlPoint *cp;
    NSPoint p;
    double t;
} hitData;

@class GRDocView;

@interface GRBezierPath : NSObject
{
    GRDocView *myView;
    NSBezierPath *myPath;
    GRBezierPathEditor *editor;
    float strokeColor[4], fillColor[4];
    float strokeAlpha, fillAlpha;
    float flatness, miterlimit, linewidth;
    int linejoin, linecap;
    BOOL stroked, filled;
    BOOL visible, locked;
    BOOL calculatingHandles;
    NSMutableArray *controlPoints;
    GRBezierControlPoint *currentPoint;
    float zmFactor;
}

- (id)initInView:(GRDocView *)aView zoomFactor:(float)zf;

- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(float)zf;

- (GRBezierPathEditor *)editor;

- (id)duplicate;

- (NSDictionary *)objectDescription;


- (void)addControlAtPoint:(NSPoint)aPoint;
- (void)addLineToPoint:(NSPoint)aPoint;
- (void)addCurveWithBezierHandlePosition:(NSPoint)handlePos;

- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split;

- (NSMutableArray *)controlPoints;
- (void)setCurrentPoint:(GRBezierControlPoint *)aPoint;
- (GRBezierControlPoint *)currentPoint;
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

- (void)setStroked:(BOOL)value;
- (BOOL)isStroked;
- (void)setStrokeColor:(float *)c;
- (float *)strokeColor;
- (void)setStrokeAlpha:(float)alpha;
- (float)strokeAlpha;
- (void)setFilled:(BOOL)value;
- (BOOL)isFilled;
- (void)setFillColor:(float *)c;
- (float *)fillColor;
- (void)setFillAlpha:(float)alpha;
- (float)fillAlpha;
- (BOOL)visible;
- (void)setVisible:(BOOL)value;
- (BOOL)locked;
- (void)setLocked:(BOOL)value;


- (void)unselectOtherControls:(GRBezierControlPoint *)cp;


- (void)remakePath;

- (NSPoint)moveControlAtPoint:(NSPoint)p;
- (void)moveControlAtPoint:(NSPoint)oldp toPoint:(NSPoint)newp;
- (NSPoint)moveBezierHandleAtPoint:(NSPoint)p;
- (void)moveBezierHandleAtPoint:(NSPoint)oldp toPoint:(NSPoint)newp;

- (hitData)hitDataOfPathSegmentOwningPoint:(NSPoint)pt;

- (void)moveAddingCoordsOfPoint:(NSPoint)p;

- (void)setZoomFactor:(float)f;

- (BOOL)onPathBorder:(NSPoint)p;

- (GRBezierControlPoint *)firstPoint;
- (GRBezierControlPoint *)currentPoint;
- (GRBezierControlPoint *)lastPoint;

- (int)indexOfPoint:(GRBezierControlPoint *)aPoint;

- (GRDocView *)view;

- (void)draw;

@end

