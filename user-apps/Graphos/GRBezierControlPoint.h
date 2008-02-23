#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef struct {
    NSPoint firstHandle;
    NSRect firstHandleRect;
    NSPoint center;
    NSRect centerRect;
    NSPoint secondHandle;
    NSRect secondHandleRect;
} GRBezierHandle;

@class GRBezierPath;

@interface GRBezierControlPoint : NSObject
{
    GRBezierPath *path;
    GRBezierHandle bzHandle;
    BOOL isActiveHandle;
    BOOL isSelect;
    float zmFactor;
}

- (id)initAtPoint:(NSPoint)aPoint
        forPath:(GRBezierPath *)aPath
       zoomFactor:(float)zf;

- (void)calculateBezierHandles:(NSPoint)draggedHandlePosition;
- (void)moveToPoint:(NSPoint)p;
- (void)moveBezierHandleToPosition:(NSPoint)newp oldPosition:(NSPoint)oldp;

- (void)setZoomFactor:(float)f;

- (GRBezierHandle)bzHandle;
- (NSPoint)center;
- (NSRect)centerRect;

- (void)select;
- (void)unselect;
- (BOOL)isSelect;
- (BOOL)isActiveHandle;

@end

