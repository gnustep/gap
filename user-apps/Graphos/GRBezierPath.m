//
//  GRBezierPath.m
//  Graphos
//
//  Created by Riccardo Mottola on Sat Feb 23 2008.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import "GRBezierPath.h"
#import "GRDocView.h"
#import "GRFunctions.h"
#import "GRBezierPathEditor.h"

static double k = 0.025;

@implementation GRBezierPath

- (id)initInView:(GRDocView *)aView zoomFactor:(float)zf
{
    self = [super init];
    if(self)
    {
        myView = aView;
        zmFactor = zf;
        myPath = [[NSBezierPath bezierPath] retain];
        [myPath setCachesBezierPath: NO];
        controlPoints = [[NSMutableArray alloc] initWithCapacity: 1];
        flatness = 0.0;
        miterlimit = 2.0;
        linewidth = 1.5;
        linejoin = 0;
        linecap = 0;
        stroked = YES;
        filled = NO;
        visible = YES;
        locked = NO;
        strokeColor[0] = 0;
        strokeColor[1] = 0;
        strokeColor[2] = 0;
        strokeColor[3] = 1;
        fillColor[0] = 0;
        fillColor[1] = 0;
        fillColor[2] = 0;
        fillColor[3] = 0;
        strokeAlpha = 1;
        fillAlpha = 1;
        editor = [[GRBezierPathEditor alloc] initEditor:self];
    }
    return self;
}

- (id)initFromData:(NSDictionary *)description
        inView:(GRDocView *)aView
        zoomFactor:(float)zf
{
    NSArray *psops, *linearr;
    NSString *str;
    NSPoint p, pp[3];
    GRBezierControlPoint *prevcp;
    double distx, disty;
    int i, count;

    self = [super init];
    if(self != nil)
    {
        editor = [[GRBezierPathEditor alloc] initEditor:self];
        myView = aView;
        zmFactor = zf;
        myPath = [[NSBezierPath bezierPath] retain];
        [myPath setCachesBezierPath: NO];
        controlPoints = [[NSMutableArray alloc] initWithCapacity: 1];
        psops = [description objectForKey: @"psdata"];
        for(i = 0; i < [psops count]; i++) {
            linearr = [[psops objectAtIndex: i] componentsSeparatedByString: @" "];
            count = [linearr count];
            str = [linearr objectAtIndex: count -1];

            if([str isEqualToString: @"moveto"]) {
                pp[0].x = [[linearr objectAtIndex: 0] floatValue];
                pp[0].y = [[linearr objectAtIndex: 1] floatValue];
                [self addControlAtPoint: pp[0]];
            }

            if([str isEqualToString: @"lineto"]) {
                pp[0].x = [[linearr objectAtIndex: 0] floatValue];
                pp[0].y = [[linearr objectAtIndex: 1] floatValue];
                [self addLineToPoint: pp[0]];
            }

            if([str isEqualToString: @"curveto"]) {
                pp[0].x = [[linearr objectAtIndex: 0] floatValue];
                pp[0].y = [[linearr objectAtIndex: 1] floatValue];
                pp[1].x = [[linearr objectAtIndex: 2] floatValue];
                pp[1].y = [[linearr objectAtIndex: 3] floatValue];
                pp[2].x = [[linearr objectAtIndex: 4] floatValue];
                pp[2].y = [[linearr objectAtIndex: 5] floatValue];

                [self addControlAtPoint: pp[2]];
                prevcp = [controlPoints objectAtIndex: [controlPoints count] -2];
                [prevcp calculateBezierHandles: pp[0]];

                distx = max(pp[1].x, pp[2].x) - min(pp[1].x, pp[2].x);
                if(pp[1].x > pp[2].x)
                    p.x = pp[2].x - distx;
                else
                    p.x = pp[2].x + distx;

                disty = max(pp[1].y, pp[2].y) - min(pp[1].y, pp[2].y);
                if(pp[1].y > pp[2].y)
                    p.y = pp[2].y - disty;
                else
                    p.y = pp[2].y + disty;

                [self addCurveWithBezierHandlePosition: p];
                [self confirmNewCurve];
            }
        }

        flatness = [[description objectForKey: @"flatness"] floatValue];
        linejoin = [[description objectForKey: @"linejoin"] intValue];
        linecap = [[description objectForKey: @"linecap"] intValue];
        miterlimit = [[description objectForKey: @"miterlimit"] floatValue];
        linewidth = [[description objectForKey: @"linewidth"] floatValue];

        stroked = (BOOL)[[description objectForKey: @"stroked"] intValue];
        str = [description objectForKey: @"strokecolor"];
        linearr = [str componentsSeparatedByString: @" "];
        strokeColor[0] = [[linearr objectAtIndex: 0] floatValue];
        strokeColor[1] = [[linearr objectAtIndex: 1] floatValue];
        strokeColor[2] = [[linearr objectAtIndex: 2] floatValue];
        strokeColor[3] = [[linearr objectAtIndex: 3] floatValue];
        strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];

        filled = (BOOL)[[description objectForKey: @"filled"] intValue];
        str = [description objectForKey: @"fillcolor"];
        linearr = [str componentsSeparatedByString: @" "];
        fillColor[0] = [[linearr objectAtIndex: 0] floatValue];
        fillColor[1] = [[linearr objectAtIndex: 1] floatValue];
        fillColor[2] = [[linearr objectAtIndex: 2] floatValue];
        fillColor[3] = [[linearr objectAtIndex: 3] floatValue];
        fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];

        visible = (BOOL)[[description objectForKey: @"visible"] intValue];
        locked = (BOOL)[[description objectForKey: @"locked"] intValue];
    }

    return self;
}

- (id)duplicate
{
    GRBezierPath *bzpath;
    GRBezierControlPoint *cp;
    GRBezierHandle handle;
    int i;

    bzpath = [[[GRBezierPath alloc]
                initInView: myView zoomFactor: zmFactor] autorelease];
    for(i = 0; i < [controlPoints count]; i++)
    {
        cp = [controlPoints objectAtIndex: i];
        [bzpath addControlAtPoint: [cp center]];
        if([cp isActiveHandle])
        {
            handle = [cp bzHandle];
            [bzpath addCurveWithBezierHandlePosition: handle.firstHandle];
            [bzpath confirmNewCurve];
        } else
        {
            if(i != 0)
                [bzpath addLineToPoint: [cp center]];
        }
    }

    [bzpath setFlat: flatness];
    [bzpath setLineJoin: linejoin];
    [bzpath setLineCap: linecap];
    [bzpath setMiterLimit: miterlimit];
    [bzpath setLineWidth: linewidth];
    [bzpath setStroked: stroked];
    [bzpath setStrokeColor: strokeColor];
    [bzpath setStrokeAlpha: strokeAlpha];
    [bzpath setFilled: filled];
    [bzpath setFillColor: fillColor];
    [bzpath setFillAlpha: fillAlpha];
    [bzpath setVisible: visible];
    [bzpath setLocked: locked];
    [[bzpath editor] setIsValid: NO];

    return bzpath;
}

- (GRBezierPathEditor *)editor
{
    return editor;
}

- (NSDictionary *)objectDescription
{
    NSMutableDictionary *dict;
    NSMutableArray *psops;
    NSString *str;
    NSBezierPathElement type;
    NSPoint p[3];
    int i;

    dict = [NSMutableDictionary dictionaryWithCapacity: 1];
    [dict setObject: @"path" forKey: @"type"];

    str = [NSString stringWithFormat: @"%.3f", flatness];
    [dict setObject: str forKey: @"flatness"];
    str = [NSString stringWithFormat: @"%i", linejoin];
    [dict setObject: str forKey: @"linejoin"];
    str = [NSString stringWithFormat: @"%i", linecap];
    [dict setObject: str forKey: @"linecap"];
    str = [NSString stringWithFormat: @"%.3f", miterlimit];
    [dict setObject: str forKey: @"miterlimit"];
    str = [NSString stringWithFormat: @"%.3f", linewidth];
    [dict setObject: str forKey: @"linewidth"];
    str = [NSString stringWithFormat: @"%i", stroked];
    [dict setObject: str forKey: @"stroked"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f",
        strokeColor[0], strokeColor[1], strokeColor[2], strokeColor[3]];
    [dict setObject: str forKey: @"strokecolor"];
    str = [NSString stringWithFormat: @"%.3f", strokeAlpha];
    [dict setObject: str forKey: @"strokealpha"];
    str = [NSString stringWithFormat: @"%i", filled];
    [dict setObject: str forKey: @"filled"];
    str = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f",
        fillColor[0], fillColor[1], fillColor[2], fillColor[3]];
    [dict setObject: str forKey: @"fillcolor"];
    str = [NSString stringWithFormat: @"%.3f", fillAlpha];
    [dict setObject: str forKey: @"fillalpha"];
    str = [NSString stringWithFormat: @"%i", visible];
    [dict setObject: str forKey: @"visible"];
    str = [NSString stringWithFormat: @"%i", locked];
    [dict setObject: str forKey: @"locked"];

    psops = [NSMutableArray arrayWithCapacity: 1];
    for(i = 0; i < [myPath elementCount]; i++)
    {
        type = [myPath elementAtIndex: i associatedPoints: p];
        if(type == NSMoveToBezierPathElement)
            str = [NSString stringWithFormat: @"%.3f %.3f moveto", p[0].x, p[0].y];
        else if(type == NSLineToBezierPathElement)
            str = [NSString stringWithFormat: @"%.3f %.3f lineto", p[0].x, p[0].y];
        else if(type == NSCurveToBezierPathElement)
            str = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f %.3f %.3f curveto",
                p[0].x, p[0].y, p[1].x, p[1].y, p[2].x, p[2].y];
        [psops addObject: str];
    }
    [dict setObject: psops forKey: @"psdata"];

    return dict;
}

// FIXME probably useless or should be rewritten non-PS anyway
/*
- (NSString *)psDescription
{
    NSString *pss;
    NSBezierPathElement type;
    NSPoint p[3];
    int i;

    if(!visible)
        return nil;

    pss = [NSString stringWithFormat:
        @"n\n%.3f i\n%i J\n%i j\n%.3f w\n%.3f M\n[]0 d\n",
        flatness, linecap, linejoin, linewidth, miterlimit];

    for(i = 0; i < [myPath elementCount]; i++)
    {
        type = [myPath elementAtIndex: i associatedPoints: p];
        if(type == NSMoveToBezierPathElement)
            pss = [pss stringByAppendingFormat: @"%.3f %.3f m\n", p[0].x, p[0].y];
        else if(type == NSLineToBezierPathElement)
            pss = [pss stringByAppendingFormat: @"%.3f %.3f l\n", p[0].x, p[0].y];
        else if(type == NSCurveToBezierPathElement)
            pss = [pss stringByAppendingFormat: @"%.3f %.3f %.3f %.3f %.3f %.3f c\n",
                p[0].x, p[0].y, p[1].x, p[1].y, p[2].x, p[2].y];
    }
    if(stroked)
        pss = [pss stringByAppendingFormat: @"%.3f %.3f %.3f %.3f k\nstroke\n",
            strokeColor[0], strokeColor[1], strokeColor[2], strokeColor[3]];
    if(filled)
        pss = [pss stringByAppendingFormat: @"%.3f %.3f %.3f %.3f k\nfill\n",
            fillColor[0], fillColor[1], fillColor[2], fillColor[3]];

    return pss;
}
*/

- (void)dealloc
{
    [myPath release];
    [controlPoints release];
    [super dealloc];
}

- (NSMutableArray *)controlPoints
{
    return controlPoints;
}


- (void)addControlAtPoint:(NSPoint)aPoint
{
    GRBezierControlPoint *cp;

    cp = [[GRBezierControlPoint alloc] initAtPoint: aPoint
                                         forPath: self zoomFactor: zmFactor];
    [controlPoints addObject: cp];
    [cp select];
    currentPoint = cp;
    [cp release];

    if([controlPoints count] == 1)
        [myPath moveToPoint: aPoint];
}

- (void)addLineToPoint:(NSPoint)aPoint
{
    GRBezierControlPoint *mtopoint, *prevpoint;
    GRBezierHandle handle;

    [self addControlAtPoint: aPoint];
    mtopoint = [controlPoints objectAtIndex: 0];
    prevpoint = [controlPoints objectAtIndex: [controlPoints count] -2];

    if([prevpoint isActiveHandle])
    {
        handle = [prevpoint bzHandle];
        [myPath curveToPoint: [currentPoint center]
               controlPoint1: handle.firstHandle
               controlPoint2: [currentPoint center]];
        [self confirmNewCurve];
        return;
    }

    if([self isPoint: currentPoint onPoint: mtopoint])
    {
        [currentPoint moveToPoint: [mtopoint center]];
        [myPath lineToPoint: [mtopoint center]];
        [editor setIsDone:YES];
    } else {
        [myPath lineToPoint: aPoint];
    }
}

- (void)addCurveWithBezierHandlePosition:(NSPoint)handlePos
{
    GRBezierControlPoint *mtopoint;
    GRBezierHandle handle1, handle2;
    NSBezierPathElement type;
    NSPoint pts[3];

    mtopoint = [controlPoints objectAtIndex: 0];
    if([self isPoint: currentPoint onPoint: mtopoint] && [controlPoints count] != 1)
    {
        if(!calculatingHandles)
        {
            [currentPoint moveToPoint: [mtopoint center]];
        } else
        {
            [mtopoint calculateBezierHandles: handlePos];
            type = [myPath elementAtIndex: 1];
            if(type == NSCurveToBezierPathElement)
            {

                [myPath elementAtIndex: 1 associatedPoints: pts];
                pts[0].x = [mtopoint bzHandle].firstHandle.x;
                pts[0].y = [mtopoint bzHandle].firstHandle.y;
                [myPath setAssociatedPoints: pts atIndex: 1];

            } else  {
                [self remakePath];
            }
        }
    }

    [currentPoint calculateBezierHandles: handlePos];
    if([controlPoints count] == 1)
        return;

    handle1 = [[controlPoints objectAtIndex: [controlPoints count] -2] bzHandle];
    handle2 = [currentPoint bzHandle];

    if(calculatingHandles) {
        pts[0].x = handle1.firstHandle.x;
        pts[0].y = handle1.firstHandle.y;
        pts[1].x = handle2.secondHandle.x;
        pts[1].y = handle2.secondHandle.y;
        pts[2].x = [currentPoint center].x;
        pts[2].y = [currentPoint center].y;
        [myPath setAssociatedPoints: pts atIndex: [controlPoints count] -1];
    } else
    {
        [myPath curveToPoint: [currentPoint center]
               controlPoint1: handle1.firstHandle
               controlPoint2: handle2.secondHandle];
        calculatingHandles = YES;
    }
}

- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split
{
    GRBezierControlPoint *ncp, *prevcp, *nextcp, *cp = nil;
    GRBezierHandle handle1, handle2;
    hitData hitdata;
    NSPoint pp[81], newpp[7];
    int i, pcount, index;
    double y, s, ax, ay;

//    printf("%s\n", [[self psDescription] cString]);
    return;
    // #### FIXME what the crap is this? we always return... the rest of the method is useless!!!
    pcount = 0;
    y = (int)p.y -4;
    while(pcount < 81) {
        for(i = -4; i <= 4; i++)
        {
            pp[pcount].x = (int)p.x + i;
            pp[pcount].y = y;
            pcount++;
        }
        y++;
    }

    for(i = 0; i < 81; i++)
    {
        hitdata = [self hitDataOfPathSegmentOwningPoint: p];
        cp = hitdata.cp;
        if(cp)
            break;
    }
    if(cp == nil)
        return;

    index = [self indexOfPoint: cp];

    ncp = [[GRBezierControlPoint alloc] initAtPoint: hitdata.p
                                          forPath: self zoomFactor: zmFactor];
    [controlPoints insertObject: ncp atIndex: index];
    [ncp select];
    currentPoint = ncp;
    [ncp release];

    if(index == 0)
        prevcp = [controlPoints objectAtIndex: [controlPoints count] -1];
    else
        prevcp = [controlPoints objectAtIndex: index -1];

    nextcp = [controlPoints objectAtIndex: index +1];

    s = 1 - hitdata.t;

    newpp[0].x = [prevcp center].x;
    newpp[0].y = [prevcp center].y;
    newpp[6].x = [nextcp center].x;
    newpp[6].y = [nextcp center].y;

    handle1 = [prevcp bzHandle];
    handle2 = [nextcp bzHandle];

    ax = s * handle1.firstHandle.x + hitdata.t * handle2.secondHandle.x;
    ay = s * handle1.firstHandle.y + hitdata.t * handle2.secondHandle.y;

    newpp[1].x = s * newpp[0].x + hitdata.t * handle1.firstHandle.x;
    newpp[1].y = s * newpp[0].y + hitdata.t * handle1.firstHandle.y;
    newpp[2].x = s * newpp[1].x + hitdata.t * ax;
    newpp[2].y = s * newpp[1].y + hitdata.t * ay;

    newpp[5].x = s *  newpp[2].x + hitdata.t * newpp[6].x;
    newpp[5].y = s *  newpp[2].y + hitdata.t * newpp[6].y;
    newpp[4].x = s * ax + hitdata.t * newpp[5].x;
    newpp[4].y = s * ay + hitdata.t * newpp[5].y;

    newpp[3].x = s * newpp[2].x + hitdata.t * newpp[4].x;
    newpp[3].y = s * newpp[2].y + hitdata.t * newpp[4].y;


    printf("%i %i - %i %i\n", (int)[currentPoint center].x,
           (int)[currentPoint center].y, (int)newpp[3].x, (int)newpp[3].y);


    [prevcp calculateBezierHandles: newpp[1]];
    [currentPoint calculateBezierHandles: newpp[4]];
    //	[nextcp calculateBezierHandles: newpp[5]];

    [self remakePath];
}

- (BOOL)isPoint:(GRBezierControlPoint *)cp1 onPoint:(GRBezierControlPoint *)cp2
{
    return pointInRect([cp2 centerRect], [cp1 center]);
}

- (GRBezierControlPoint *)pointOnPoint:(GRBezierControlPoint *)aPoint
{
    GRBezierControlPoint *cp, *ponpoint = nil;
    int i;

    for(i = 0; i < [controlPoints count]; i++)
    {
        cp = [controlPoints objectAtIndex: i];
        if([self isPoint: aPoint onPoint: cp] && (aPoint != cp))
        {
            ponpoint = cp;
            break;
        }
    }

    return ponpoint;
}

- (void)confirmNewCurve
{
    calculatingHandles = NO;
    if([controlPoints count] == 1)
        return;
    if([self isPoint: currentPoint onPoint: [controlPoints objectAtIndex: 0]])
        [editor setIsDone:YES];
}

- (void)remakePath
{
    GRBezierControlPoint *cp, *prevcp, *mtopoint;
    GRBezierHandle handle1, handle2;
    int i;

    [myPath removeAllPoints];
    mtopoint = [controlPoints objectAtIndex: 0];
    [myPath moveToPoint: [mtopoint center]];
    for(i = 1; i < [controlPoints count]; i++)
    {
        cp = [controlPoints objectAtIndex: i];
        prevcp = [controlPoints objectAtIndex: i -1];
        if([prevcp isActiveHandle] || [cp isActiveHandle])
        {
            handle1 = [prevcp bzHandle];
            handle2 = [cp bzHandle];
            [myPath curveToPoint: [cp center]
                   controlPoint1: handle1.firstHandle
                   controlPoint2: handle2.secondHandle];
        } else
        {
            [myPath lineToPoint: [cp center]];
        }
        if([self isPoint: cp onPoint: mtopoint])
            [editor setIsDone:YES];
    }
}


- (hitData)hitDataOfPathSegmentOwningPoint:(NSPoint)pt
{
    hitData hitdata;
    GRBezierControlPoint *cp, *prevcp;
    GRBezierHandle handle1, handle2;
    NSPoint p, bp;
    NSRect r;
    double t;
    int i;

    hitdata.cp = nil;
    r = NSMakeRect((int)pt.x -4, (int)pt.y -4, 8, 8);

    for(i = 0; i < [controlPoints count]; i++)
    {
        cp = [controlPoints objectAtIndex: i];

        if(pointInRect([cp centerRect], pt))
            return hitdata;

        if(i == 0)
            prevcp = [controlPoints objectAtIndex: [controlPoints count] -1];
        else
            prevcp = [controlPoints objectAtIndex: i -1];

        handle1 = [prevcp bzHandle];
        handle2 = [cp bzHandle];

        bp.x = [prevcp center].x;
        bp.y = [prevcp center].y;
        for(t = k; t <= 1+k; t += k) {
            p.x = (bp.x+t*(-bp.x*3+t*(3*bp.x-bp.x*t)))
            +t*(3*handle1.firstHandle.x+t*
                (-6*handle1.firstHandle.x+handle1.firstHandle.x*3*t))
            +t*t*(handle2.secondHandle.x*3-handle2.secondHandle.x*3*t)
            +[cp center].x*t*t*t;
            p.y = (bp.y+t*(-bp.y*3+t*(3*bp.y-bp.y*t)))
                +t*(3*handle1.firstHandle.y+t*
                    (-6*handle1.firstHandle.y+handle1.firstHandle.y*3*t))
                +t*t*(handle2.secondHandle.y*3-handle2.secondHandle.y*3*t)
                +[cp center].y*t*t*t;

            if(pointInRect(r, p))
            {
                hitdata.cp = cp;
                hitdata.p.x = p.x;
                hitdata.p.y = p.y;
                hitdata.t = t - k;
                return hitdata;
            }
        }
    }

    return hitdata;
}

- (void)moveAddingCoordsOfPoint:(NSPoint)p
{
    int i;

    for(i = 0; i < [controlPoints count]; i++)
    {
        GRBezierControlPoint *cp = [controlPoints objectAtIndex: i];
        [cp moveToPoint: NSMakePoint([cp center].x + p.x, [cp center].y + p.y)];
    }
    [self remakePath];
}

- (void)setZoomFactor:(float)f
{
    int i;

    linewidth = linewidth / zmFactor * f;

    zmFactor = f;
    for(i = 0; i < [controlPoints count]; i++)
        [[controlPoints objectAtIndex: i] setZoomFactor: zmFactor];

    [self remakePath];
}

- (BOOL)onPathBorder:(NSPoint)p
{
    int i;
    GRBezierControlPoint *cp;
    GRBezierHandle handle;

    for(i = 0; i < [controlPoints count]; i++)
    {
        cp = [controlPoints objectAtIndex: i];
        handle = [cp bzHandle];
        if(pointInRect(handle.centerRect, p))
            return YES;
    }

    if([myPath containsPoint: p])
        return YES;

    return NO;
}

- (GRBezierControlPoint *)firstPoint
{
    return (GRBezierControlPoint *)[controlPoints objectAtIndex: 0];
}

- (void)setCurrentPoint:(GRBezierControlPoint *)aPoint
{
    currentPoint = aPoint;
}

- (GRBezierControlPoint *)currentPoint
{
    return currentPoint;
}

- (GRBezierControlPoint *)lastPoint
{
    return (GRBezierControlPoint *)[controlPoints objectAtIndex: [controlPoints count] -1];
}

- (int)indexOfPoint:(GRBezierControlPoint *)aPoint
{
    int i = -1;

    for(i = 0; i < [controlPoints count]; i++)
        if([controlPoints objectAtIndex: i] == aPoint)
            break;

    return i;
}


- (void)setFlat:(float)flat
{
    flatness = flat;
}

- (float)flatness
{
    return flatness;
}

- (void)setLineJoin:(int)join
{
    linejoin = join;
}

- (int)lineJoin
{
    return linejoin;
}

- (void)setLineCap:(int)cap
{
    linecap = cap;
}

- (int)lineCap
{
    return linecap;
}

- (void)setMiterLimit:(float)limit
{
    miterlimit = limit;
}

- (float)miterLimit
{
    return miterlimit;
}

- (void)setLineWidth:(float)width
{
    linewidth = width;
}

- (float)lineWidth
{
    return linewidth;
}

- (void)setStroked:(BOOL)value
{
    stroked = value;
}

- (BOOL)isStroked
{
    return stroked;
}

- (void)setStrokeColor:(float *)c
{
    int i;

    for(i = 0; i < 4; i++)
        strokeColor[i] = c[i];
}

- (float *)strokeColor
{
    return strokeColor;
}

- (void)setStrokeAlpha:(float)alpha
{
    strokeAlpha = alpha;
}

- (float)strokeAlpha
{
    return strokeAlpha;
}

- (void)setFilled:(BOOL)value
{
    filled = value;
}

- (BOOL)isFilled
{
    return filled;
}

- (void)setFillColor:(float *)c
{
    int i;

    for(i = 0; i < 4; i++)
        fillColor[i] = c[i];
}

- (float *)fillColor
{
    return fillColor;
}

- (void)setFillAlpha:(float)alpha
{
    fillAlpha = alpha;
}

- (float)fillAlpha
{
    return fillAlpha;
}

- (BOOL)visible
{
    return visible;
}

- (void)setVisible:(BOOL)value
{
    visible = value;
    if(!visible)
        [editor unselect];
}

- (BOOL)locked
{
    return locked;
}

- (void)setLocked:(BOOL)value
{
    locked = value;
    if(!locked)
        [editor unselect];
    else
        [editor selectAsGroup];
}




- (void)unselectOtherControls:(GRBezierControlPoint *)cp
{
    GRBezierControlPoint *ctrlp;
    int i;

    currentPoint = cp;
    for(i = 0; i < [controlPoints count]; i++) {
        ctrlp = [controlPoints objectAtIndex: i];
        if(ctrlp != cp)
            [ctrlp unselect];
    }
}


- (GRDocView *)view
{
    return myView;
}

- (void)draw
{
    GRBezierControlPoint *cp, *ponpoint = nil;
    NSRect r;
    GRBezierHandle bzhandle;
    NSColor *color;
    int i;
    NSBezierPath *bzp;

    if(![controlPoints count] || !visible)
        return;

    bzp = [NSBezierPath bezierPath];
    if(stroked)
    {
        NSLog(@"line width: %f", linewidth);
        [NSGraphicsContext saveGraphicsState];
        [myPath setLineJoinStyle:linejoin];
        [myPath setLineCapStyle:linecap];
        [myPath setLineWidth:linewidth];
        // #### and alpha strokeAlpha ????
        color = [NSColor colorWithDeviceCyan: strokeColor[0]
                                     magenta: strokeColor[1]
                                      yellow: strokeColor[2]
                                       black: strokeColor[3]
                                       alpha: strokeAlpha];
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        [color set];
        [myPath stroke];   // FIXME why this twice... need to understand mypath
        [NSGraphicsContext restoreGraphicsState];
    }

    if(filled)
    {
        // #### and alpha strokeAlpha ????
        [NSGraphicsContext saveGraphicsState];
        //		PSsetalpha(fillAlpha);
        color = [NSColor colorWithDeviceCyan: fillColor[0]
                                     magenta: fillColor[1]
                                      yellow: fillColor[2]
                                       black: fillColor[3]
                                       alpha: fillAlpha];
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        [color set];
        [myPath fill];
        [NSGraphicsContext restoreGraphicsState];
    }

    [bzp setLineWidth:1];
    if([editor isGroupSelected])
    {
        for(i = 0; i < [controlPoints count]; i++)
        {
            cp = [controlPoints objectAtIndex: i];
            r = [cp centerRect];
            [[NSColor blackColor] set];
            NSRectFill(r);
        }
    }
// shall be done from the editor ??
    if([editor isEditSelected])
    {
        for(i = 0; i < [controlPoints count]; i++)
        {
            cp = [controlPoints objectAtIndex: i];
            r = [cp centerRect];
            if([cp isSelect]) {
                [[NSColor blackColor] set];
                NSRectFill(r);
                if([cp isActiveHandle]) {
                    bzhandle = [cp bzHandle];
                    [[NSColor blackColor] set];
                    NSRectFill(bzhandle.firstHandleRect);
                    [bzp moveToPoint:NSMakePoint(bzhandle.firstHandle.x, bzhandle.firstHandle.y)];
                    [bzp lineToPoint:NSMakePoint(bzhandle.center.x, bzhandle.center.y)];
                    [bzp lineToPoint:NSMakePoint(bzhandle.secondHandle.x, bzhandle.secondHandle.y)];
                    [bzp stroke];
                    NSRectFill(bzhandle.secondHandleRect);
                }
            } else
            {
                [[NSColor whiteColor] set];
                NSRectFill(r);

                ponpoint = [self pointOnPoint: cp];
                if(ponpoint)
                {
                    if([ponpoint isSelect])
                    {
                        r = [ponpoint centerRect];
                        [[NSColor blackColor] set];
                        NSRectFill(r);
                        if([ponpoint isActiveHandle])
                        {
                            bzhandle = [ponpoint bzHandle];
                            [[NSColor blackColor] set];
                            NSRectFill(bzhandle.firstHandleRect);
                            [bzp moveToPoint:NSMakePoint(bzhandle.firstHandle.x, bzhandle.firstHandle.y)];
                            [bzp lineToPoint:NSMakePoint(bzhandle.center.x, bzhandle.center.y)];
                            [bzp lineToPoint:NSMakePoint(bzhandle.secondHandle.x, bzhandle.secondHandle.y)];
                            [bzp stroke];
                            NSRectFill(bzhandle.secondHandleRect);
                        }
                    }
                }

            }
            [[NSColor blackColor] set];
            NSFrameRect(r);
        }
    }
}

@end
