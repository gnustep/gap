#import "GRBezierControlPoint.h"
#import "GRBezierPathEditor.h"
#import "GRFunctions.h"

@implementation GRBezierControlPoint

- (id)initAtPoint:(NSPoint)aPoint
        forEditor:(GRBezierPathEditor *)editor
       zoomFactor:(float)zf
{
    self = [super init];
    if(self) {
        myEditor = editor;
        zmFactor = zf;
        bzHandle.center = aPoint;
        bzHandle.centerRect = NSMakeRect(aPoint.x-3, aPoint.y-3, 6, 6);
        [self calculateBezierHandles: aPoint];
        isSelect = NO;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)calculateBezierHandles:(NSPoint)draggedHandlePos
{
    double distx, disty;

    bzHandle.firstHandle = draggedHandlePos;
    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);

    distx = max(bzHandle.firstHandle.x, bzHandle.center.x) - min(bzHandle.firstHandle.x, bzHandle.center.x);
    if(bzHandle.firstHandle.x > bzHandle.center.x)
        bzHandle.secondHandle.x = bzHandle.center.x - distx;
    else
        bzHandle.secondHandle.x = bzHandle.center.x + distx;

    disty = max(bzHandle.firstHandle.y, bzHandle.center.y) - min(bzHandle.firstHandle.y, bzHandle.center.y);
    if(bzHandle.firstHandle.y > bzHandle.center.y)
        bzHandle.secondHandle.y = bzHandle.center.y - disty;
    else
        bzHandle.secondHandle.y = bzHandle.center.y + disty;

    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);

    if(distx || disty)
        isActiveHandle = YES;
}

- (void)moveToPoint:(NSPoint)p
{
    double xdiff, ydiff;

    xdiff = p.x - bzHandle.center.x;
    ydiff = p.y - bzHandle.center.y;
    bzHandle.center.x += xdiff;
    bzHandle.center.y += ydiff;
    bzHandle.centerRect = NSMakeRect(bzHandle.center.x-3, bzHandle.center.y-3, 6, 6);
    bzHandle.firstHandle.x += xdiff;
    bzHandle.firstHandle.y += ydiff;
    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
    bzHandle.secondHandle.x += xdiff;
    bzHandle.secondHandle.y += ydiff;
    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);
}

- (void)moveBezierHandleToPosition:(NSPoint)newp oldPosition:(NSPoint)oldp
{
    GRBezierControlPoint *mtopoint, *ponpoint = nil;
    double distx, disty;

    mtopoint = [myEditor firstPoint];
    ponpoint = [myEditor pointOnPoint: self];
    if(ponpoint && [myEditor isdone] && (self == mtopoint))
        [ponpoint moveBezierHandleToPosition: newp oldPosition: oldp];

    if(pointInRect(bzHandle.firstHandleRect, oldp)) {
        bzHandle.firstHandle = newp;
        distx = max(bzHandle.firstHandle.x, bzHandle.center.x) - min(bzHandle.firstHandle.x, bzHandle.center.x);
        disty = max(bzHandle.firstHandle.y, bzHandle.center.y) - min(bzHandle.firstHandle.y, bzHandle.center.y);
        if(bzHandle.firstHandle.x > bzHandle.center.x)
            bzHandle.secondHandle.x = bzHandle.center.x - distx;
        else
            bzHandle.secondHandle.x = bzHandle.center.x + distx;
        if(bzHandle.firstHandle.y > bzHandle.center.y)
            bzHandle.secondHandle.y = bzHandle.center.y - disty;
        else
            bzHandle.secondHandle.y = bzHandle.center.y + disty;
    }

    if(pointInRect(bzHandle.secondHandleRect, oldp)) {
        bzHandle.secondHandle = newp;
        distx = max(bzHandle.secondHandle.x, bzHandle.center.x) - min(bzHandle.secondHandle.x, bzHandle.center.x);
        disty = max(bzHandle.secondHandle.y, bzHandle.center.y) - min(bzHandle.secondHandle.y, bzHandle.center.y);
        if(bzHandle.secondHandle.x > bzHandle.center.x)
            bzHandle.firstHandle.x = bzHandle.center.x - distx;
        else
            bzHandle.firstHandle.x = bzHandle.center.x + distx;
        if(bzHandle.secondHandle.y > bzHandle.center.y)
            bzHandle.firstHandle.y = bzHandle.center.y - disty;
        else
            bzHandle.firstHandle.y = bzHandle.center.y + disty;
    }

    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);
}

- (void)setZoomFactor:(float)f
{
    bzHandle.center.x = bzHandle.center.x / zmFactor * f;
    bzHandle.center.y = bzHandle.center.y / zmFactor * f;
    bzHandle.centerRect = NSMakeRect(bzHandle.center.x-3, bzHandle.center.y-3, 6, 6);
    bzHandle.firstHandle.x = bzHandle.firstHandle.x / zmFactor * f;
    bzHandle.firstHandle.y = bzHandle.firstHandle.y / zmFactor * f;
    bzHandle.firstHandleRect = NSMakeRect(bzHandle.firstHandle.x-2, bzHandle.firstHandle.y-2, 4, 4);
    bzHandle.secondHandle.x = bzHandle.secondHandle.x / zmFactor * f;
    bzHandle.secondHandle.y = bzHandle.secondHandle.y / zmFactor * f;
    bzHandle.secondHandleRect = NSMakeRect(bzHandle.secondHandle.x-2, bzHandle.secondHandle.y-2, 4, 4);

    zmFactor = f;
}

- (DBezierHandle)bzHandle
{
    return bzHandle;
}

- (NSPoint)center
{
    return bzHandle.center;
}

- (NSRect)centerRect;
{
    return bzHandle.centerRect;
}

- (void)select
{
    double distx, disty;

    isSelect = YES;
    [myEditor unselectOtherControls: self];
    distx = max(bzHandle.firstHandle.x, bzHandle.center.x) - min(bzHandle.firstHandle.x, bzHandle.center.x);
    disty = max(bzHandle.firstHandle.y, bzHandle.center.y) - min(bzHandle.firstHandle.y, bzHandle.center.y);
    if(distx || disty)
        isActiveHandle = YES;
}

- (void)unselect
{
    isSelect = NO;
}

- (BOOL)isSelect
{
    return isSelect;
}

- (BOOL)isActiveHandle
{
    return isActiveHandle;
}

@end
