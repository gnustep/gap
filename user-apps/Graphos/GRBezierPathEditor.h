#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRBezierControlPoint.h"

typedef struct {
	GRBezierControlPoint *cp;
	NSPoint p;
	double t;
} hitData;

@class GRDocView;

@interface GRBezierPathEditor : NSObject
{
	GRDocView *myView;
	NSBezierPath *myPath;
	float strokeColor[4], fillColor[4];
	float strokeAlpha, fillAlpha;
	float flatness, miterlimit, linewidth;
	int linejoin, linecap;
	BOOL stroked, filled;
	BOOL visible, locked;
	NSMutableArray *controlPoints;
	GRBezierControlPoint *currentPoint;
	BOOL calculatingHandles;
	BOOL groupSelected;
	BOOL editSelected;
	BOOL isdone;
	BOOL isvalid;
	float zmFactor;	
}

- (id)initInView:(GRDocView *)aView zoomFactor:(float)zf;

- (id)initFromData:(NSDictionary *)description 
                inView:(GRDocView *)aView 
                zoomFactor:(float)zf;

- (id)duplicate;

- (NSDictionary *)objectDescription;
- (NSString *)psDescription;

- (void)addControlAtPoint:(NSPoint)aPoint;
- (void)addLineToPoint:(NSPoint)aPoint;
- (void)addCurveWithBezierHandlePosition:(NSPoint)handlePos;

- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split;

- (BOOL)isPoint:(GRBezierControlPoint *)cp1 onPoint:(GRBezierControlPoint *)cp2;
- (GRBezierControlPoint *)pointOnPoint:(GRBezierControlPoint *)aPoint;
- (void)confirmNewCurve;
- (BOOL)isdone;

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
- (void)setVisible:(BOOL)value;
- (void)setLocked:(BOOL)value;

- (void)selectAsGroup;
- (void)selectForEditing;
- (void)unselect;		
- (BOOL)isGroupSelected;
- (BOOL)isEditSelected;
- (BOOL)isSelect;

- (void)unselectOtherControls:(GRBezierControlPoint *)cp;

- (void)setIsValid:(BOOL)value;

- (BOOL)isValid;

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

- (void)Draw;

@end

