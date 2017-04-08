/*
 Project: Graphos
 GRBezierPath.m

 Copyright (C) 2000-2015 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
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

#import "GRBezierPath.h"
#import "GRDocView.h"
#import "GRFunctions.h"
#import "GRBezierPathEditor.h"

static double k = 0.025;

@implementation GRBezierPath

- (GRObjectEditor *)allocEditor
{
  return [[GRBezierPathEditor alloc] initEditor:self];
}

/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(CGFloat)zf
      withProperties:(NSDictionary *)properties
{
  self = [super initInView:aView zoomFactor:zf withProperties:properties];
  if(self)
    {
      controlPoints = [[NSMutableArray alloc] initWithCapacity: 1];
    }

  return self;
}

- (id)initFromData:(NSDictionary *)description
        inView:(GRDocView *)aView
        zoomFactor:(CGFloat)zf
{
  self = [super init];
  if(self != nil)
    {
      NSArray *psops, *linearr;
      NSString *str;
      NSPoint p, pp[3];
      GRBezierControlPoint *prevcp;
      double distx, disty;
      NSUInteger i, count;
      NSArray *points;
      CGFloat strokeCol[4];
      CGFloat fillCol[4];
      CGFloat strokeAlpha;
      CGFloat fillAlpha;
      id obj;
      BOOL symm;
      
      psops = nil;
      linearr = nil;
      docView = aView;
      zmFactor = zf;
      editor = [self allocEditor];
      myPath = [[NSBezierPath bezierPath] retain];
      [myPath setCachesBezierPath: NO];
      controlPoints = [[NSMutableArray alloc] initWithCapacity: 1];
      points = [description objectForKey: @"points"];
      for (i = 0; i < [points count]; i++)
        {
          GRBezierHandle h;
          GRBezierControlPoint *cp;

          linearr = [[points objectAtIndex: i] componentsSeparatedByString: @" "];
          h.firstHandle.x = [[linearr objectAtIndex: 0] floatValue];
          h.firstHandle.y = [[linearr objectAtIndex: 1] floatValue];
          h.firstHandleRect = NSMakeRect(h.firstHandle.x-2, h.firstHandle.y-2, 4, 4);
          h.center.x = [[linearr objectAtIndex: 2] floatValue];
          h.center.y = [[linearr objectAtIndex: 3] floatValue];
          h.centerRect = NSMakeRect(h.center.x-3, h.center.y-3, 6, 6);
          h.secondHandle.x = [[linearr objectAtIndex: 4] floatValue];
          h.secondHandle.y = [[linearr objectAtIndex: 5] floatValue];
          h.secondHandleRect = NSMakeRect(h.secondHandle.x-2, h.secondHandle.y-2, 4, 4);
          symm = (BOOL)[[linearr objectAtIndex: 6] intValue];

          cp = [[GRBezierControlPoint alloc] initAtPoint:h.center forPath:self zoomFactor:zmFactor];
          [cp setBezierHandle:h];
          [cp setSymmetricalHandles:symm];
          [controlPoints addObject:cp];
          [cp release];
        }
      [self confirmNewCurve];
      [self remakePath];
      psops = [description objectForKey: @"psdata"];
      for(i = 0; i < [psops count]; i++)
        {
	  linearr = [[psops objectAtIndex: i] componentsSeparatedByString: @" "];
	  count = [linearr count];
	  str = [linearr objectAtIndex: count -1];
	  
	  if([str isEqualToString: @"moveto"])
            {
	      pp[0].x = [[linearr objectAtIndex: 0] floatValue];
	      pp[0].y = [[linearr objectAtIndex: 1] floatValue];
	      [self addControlAtPoint: pp[0]];
            }
	  
	  if([str isEqualToString: @"lineto"])
            {
	      pp[0].x = [[linearr objectAtIndex: 0] floatValue];
	      pp[0].y = [[linearr objectAtIndex: 1] floatValue];
	      [self addLineToPoint: pp[0]];
            }
	  
	  if([str isEqualToString: @"curveto"])
            {
	      pp[0].x = [[linearr objectAtIndex: 0] floatValue];
	      pp[0].y = [[linearr objectAtIndex: 1] floatValue];
	      pp[1].x = [[linearr objectAtIndex: 2] floatValue];
	      pp[1].y = [[linearr objectAtIndex: 3] floatValue];
	      pp[2].x = [[linearr objectAtIndex: 4] floatValue];
	      pp[2].y = [[linearr objectAtIndex: 5] floatValue];
	      
	      [self addControlAtPoint: pp[2]];
	      prevcp = [controlPoints objectAtIndex: [controlPoints count] -2];
	      [prevcp calculateBezierHandles: pp[0]];
	      
	      distx = grmax(pp[1].x, pp[2].x) - grmin(pp[1].x, pp[2].x);
	      if(pp[1].x > pp[2].x)
		p.x = pp[2].x - distx;
	      else
		p.x = pp[2].x + distx;
	      
	      disty = grmax(pp[1].y, pp[2].y) - grmin(pp[1].y, pp[2].y);
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
      obj = [description objectForKey: @"stroked"];
      if ([obj isKindOfClass:[NSString class]])
	obj = [NSNumber numberWithInt:[obj intValue]];
      stroked = [obj boolValue];
      strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];
      str = [description objectForKey: @"strokecolor"];
      linearr = [str componentsSeparatedByString: @" "];
      if ([linearr count] == 3)
	{
	  strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
	  strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
	  strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
	  strokeColor = [NSColor colorWithCalibratedRed: strokeCol[0]
						  green: strokeCol[1]
						   blue: strokeCol[2]
						  alpha: strokeAlpha];
	  [strokeColor retain];
	}
      else
	{
	  strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
	  strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
	  strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
	  strokeCol[3] = [[linearr objectAtIndex: 3] floatValue];
	  strokeColor = [NSColor colorWithDeviceCyan: strokeCol[0]
					     magenta: strokeCol[1]
					      yellow: strokeCol[2]
					       black: strokeCol[3]
					       alpha: strokeAlpha];
	  strokeColor = [[strokeColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
	  }
      obj = [description objectForKey: @"filled"];
      if ([obj isKindOfClass:[NSString class]])
	obj = [NSNumber numberWithInt:[obj intValue]];
      filled = [obj boolValue];
      fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];
      str = [description objectForKey: @"fillcolor"];
      linearr = [str componentsSeparatedByString: @" "];
      if ([linearr count] == 3)
	{
	  fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
	  fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
	  fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
	  fillColor = [NSColor colorWithCalibratedRed: fillCol[0]
						green: fillCol[1]
						 blue: fillCol[2]
						alpha: fillAlpha];
	  [fillColor retain];
	}
      else
	{
	  fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
	  fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
	  fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
	  fillCol[3] = [[linearr objectAtIndex: 3] floatValue];
	  fillColor = [NSColor colorWithDeviceCyan: fillCol[0]
					   magenta: fillCol[1]
					    yellow: fillCol[2]
					     black: fillCol[3]
					     alpha: fillAlpha];
	  fillColor = [[fillColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
	}
      obj = [description objectForKey: @"visible"];
      if ([obj isKindOfClass:[NSString class]])
	obj = [NSNumber numberWithInt:[obj intValue]];
      visible = [obj boolValue];
      obj = [description objectForKey: @"locked"];
      if ([obj isKindOfClass:[NSString class]])
	obj = [NSNumber numberWithInt:[obj intValue]];
      locked = [obj boolValue];
    }

  return self;
}


- (NSDictionary *)objectDescription
{
  NSMutableDictionary *dict;
  NSMutableArray *points;
  NSString *str;
  NSUInteger i;
  CGFloat strokeCol[3];
  CGFloat fillCol[3];
  CGFloat strokeAlpha;
  CGFloat fillAlpha;

  strokeCol[0] = [strokeColor redComponent];
  strokeCol[1] = [strokeColor greenComponent];
  strokeCol[2] = [strokeColor blueComponent];
  strokeAlpha = [strokeColor alphaComponent];
 
  fillCol[0] = [fillColor redComponent];
  fillCol[1] = [fillColor greenComponent];
  fillCol[2] = [fillColor blueComponent];
  fillAlpha = [fillColor alphaComponent];

  dict = [NSMutableDictionary dictionaryWithCapacity: 1];
  [dict setObject: @"path" forKey: @"type"];

  str = [NSString stringWithFormat: @"%.3f", (float)flatness];
  [dict setObject: str forKey: @"flatness"];
  str = [NSString stringWithFormat: @"%i", linejoin];
  [dict setObject: str forKey: @"linejoin"];
  str = [NSString stringWithFormat: @"%i", linecap];
  [dict setObject: str forKey: @"linecap"];
  str = [NSString stringWithFormat: @"%.3f", (float)miterlimit];
  [dict setObject: str forKey: @"miterlimit"];
  str = [NSString stringWithFormat: @"%.3f", (float)linewidth];
  [dict setObject: str forKey: @"linewidth"];
  [dict setObject: [NSNumber numberWithBool:stroked] forKey: @"stroked"];
  str = [NSString stringWithFormat: @"%.3f %.3f %.3f",
		  (float)strokeCol[0], (float)strokeCol[1], (float)strokeCol[2]];
  [dict setObject: str forKey: @"strokecolor"];
  str = [NSString stringWithFormat: @"%.3f", (float)strokeAlpha];
  [dict setObject: str forKey: @"strokealpha"];
  [dict setObject:[NSNumber numberWithBool:filled] forKey: @"filled"];
  str = [NSString stringWithFormat: @"%.3f %.3f %.3f",
		  (float)fillCol[0], (float)fillCol[1], (float)fillCol[2]];
  [dict setObject: str forKey: @"fillcolor"];
  str = [NSString stringWithFormat: @"%.3f", (float)fillAlpha];
  [dict setObject: str forKey: @"fillalpha"];
  [dict setObject:[NSNumber numberWithBool:visible] forKey: @"visible"];
  [dict setObject:[NSNumber numberWithBool:locked] forKey: @"locked"];

  points = [NSMutableArray arrayWithCapacity: 1];
  for (i = 0; i < [controlPoints count]; i++)
    {
      GRBezierControlPoint *cp;
      GRBezierHandle handle;

      cp = [controlPoints objectAtIndex:i];
      handle = [cp bzHandle];
      str = [NSString stringWithFormat: @"%f %f %f %f %f %f %d",
                      handle.firstHandle.x, handle.firstHandle.y,
                      handle.center.x, handle.center.y,
                      handle.secondHandle.x, handle.secondHandle.y,
                      [cp symmetricalHandles]];
      [points addObject:str];
    }
  [dict setObject: points forKey:@ "points"];
  
  return dict;
}

- (id)copyWithZone:(NSZone *)zone
{
  GRBezierPath *objCopy;
  NSMutableArray *cpsCopy;
  NSEnumerator *e;
  GRBezierControlPoint *cp;
  
  objCopy = [super copyWithZone:zone];
  
  cpsCopy = [[NSMutableArray alloc] initWithCapacity: [controlPoints count]];
  e = [controlPoints objectEnumerator];
  while ((cp = [e nextObject]))
    {
      GRBezierControlPoint *cpCopy;

      cpCopy = [cp copy];
      [cpsCopy addObject: cpCopy];
      [cpCopy release];
    }
  
  objCopy->controlPoints = cpsCopy;
  objCopy->calculatingHandles = calculatingHandles;
  return objCopy;
}

- (void)dealloc
{
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
      [myPath moveToPoint: GRpointZoom(aPoint, zmFactor)];
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
      [myPath curveToPoint: [(GRBezierControlPoint *)currentPoint center]
              controlPoint1: handle.firstHandle
              controlPoint2: [(GRBezierControlPoint *)currentPoint center]];
      [self confirmNewCurve];
      return;
    }
  
  if([self isPoint: (GRBezierControlPoint *)currentPoint onPoint: mtopoint])
    {
      [currentPoint moveToPoint: [mtopoint center]];
      [myPath lineToPoint: GRpointZoom([mtopoint center], zmFactor)];
      [(GRBezierPathEditor *)editor setIsDone:YES];
    }
  else
    {
      [myPath lineToPoint: GRpointZoom(aPoint, zmFactor)];
    }
}

- (void)addCurveWithBezierHandlePosition:(NSPoint)handlePos
{
  GRBezierControlPoint *mtopoint;
  GRBezierHandle handle1, handle2;
  NSBezierPathElement type;
  NSPoint pts[3];

  mtopoint = [controlPoints objectAtIndex: 0];
  if([self isPoint: (GRBezierControlPoint *)currentPoint onPoint: mtopoint] && [controlPoints count] != 1)
    {
      if(!calculatingHandles)
        {
          [currentPoint moveToPoint:[mtopoint center]];
        }
      else
        {
          [mtopoint calculateBezierHandles: handlePos];
          type = [myPath elementAtIndex: 1];
          if(type == NSCurveToBezierPathElement)
            {
              [myPath elementAtIndex: 1 associatedPoints: pts];
              pts[0] = GRpointZoom([mtopoint bzHandle].firstHandle, zmFactor);
              
              [myPath setAssociatedPoints: pts atIndex: 1];           
            }
          else 
            {
              [self remakePath];
            }
        }
    }
  
    [(GRBezierControlPoint *)currentPoint calculateBezierHandles: handlePos];
    if([controlPoints count] == 1)
      return;
    
    handle1 = [[controlPoints objectAtIndex: [controlPoints count] -2] bzHandle];
    handle2 = [(GRBezierControlPoint *)currentPoint bzHandle];

    if(calculatingHandles)
      {
        pts[0] = GRpointZoom(handle1.firstHandle, zmFactor);
        pts[1] = GRpointZoom(handle2.secondHandle, zmFactor);
        pts[2] = GRpointZoom([(GRBezierControlPoint *)currentPoint center], zmFactor);
        [myPath setAssociatedPoints: pts atIndex: [controlPoints count] -1];
      }
    else
      {
        [myPath curveToPoint: GRpointZoom([(GRBezierControlPoint *)currentPoint center], zmFactor)
		controlPoint1: GRpointZoom(handle1.firstHandle, zmFactor)
		controlPoint2: GRpointZoom(handle2.secondHandle, zmFactor)];
        calculatingHandles = YES;
      }
}

- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split
{
    GRBezierControlPoint *ncp, *prevcp, *nextcp, *cp = nil;
    GRBezierHandle handle1, handle2;
    hitData hitdata;
    NSPoint pp[81], newpp[7];
    NSUInteger i, pcount, index;
    double y, s, ax, ay;

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
    if (index == NSNotFound)
      return;

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


    printf("%i %i - %i %i\n", (int)[(GRBezierControlPoint *)currentPoint center].x,
           (int)[(GRBezierControlPoint *)currentPoint center].y, (int)newpp[3].x, (int)newpp[3].y);


    [prevcp calculateBezierHandles: newpp[1]];
    [(GRBezierControlPoint *)currentPoint calculateBezierHandles: newpp[4]];
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
  NSUInteger i;

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
  if (!controlPoints || [controlPoints count] == 0)
    return;
  calculatingHandles = NO;
  if([controlPoints count] == 1)
    return;
  if([self isPoint: (GRBezierControlPoint *)currentPoint onPoint: [controlPoints objectAtIndex: 0]])
    [(GRBezierPathEditor *)editor setIsDone:YES];
  
  [self remakePath];
}

- (void)remakePath
{
  GRBezierControlPoint *cp, *prevcp, *mtopoint;
  NSInteger i;

  [myPath removeAllPoints];
  if (!controlPoints || [controlPoints count] == 0)
    return;

  mtopoint = [controlPoints objectAtIndex: 0];
  [myPath moveToPoint: GRpointZoom([mtopoint center], zmFactor)];
  for(i = 1; i < [controlPoints count]; i++)
    {
      GRBezierHandle handle1, handle2;
      BOOL isLine;

      cp = [controlPoints objectAtIndex: i];
      prevcp = [controlPoints objectAtIndex: i -1];
      handle1 = [prevcp bzHandle];
      handle2 = [cp bzHandle];

      /* we have a line if the start and end control points have respectively
         right and left center-coincident handles */
      isLine = NO;
      if (NSEqualPoints(handle1.center, handle1.secondHandle) && NSEqualPoints(handle2.center, handle2.firstHandle))
        isLine = YES;
      
      if (isLine)
        {
          [myPath lineToPoint: GRpointZoom([cp center], zmFactor)];
        }
      else
        {
          [myPath curveToPoint: GRpointZoom([cp center], zmFactor)
                 controlPoint1: GRpointZoom(handle1.firstHandle, zmFactor)
                 controlPoint2: GRpointZoom(handle2.secondHandle, zmFactor)];
          [cp setPointPosition:GRPointMiddle];
        }

      if([self isPoint: cp onPoint: mtopoint])
	[(GRBezierPathEditor *)editor setIsDone:YES];
    }

  /* if the path is open, set the Start ad End points controls */
  if (!NSEqualPoints([(GRBezierControlPoint *)[controlPoints objectAtIndex:0] center], [(GRBezierControlPoint *)[controlPoints objectAtIndex:[controlPoints count]-1] center]))
    {
      [[controlPoints objectAtIndex:0] setPointPosition:GRPointStart];
      [[controlPoints objectAtIndex:[controlPoints count]-1] setPointPosition:GRPointEnd];
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
    NSUInteger i;

    hitdata.cp = nil;
    hitdata.t = 0;
    hitdata.p = NSZeroPoint;

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

- (void)setZoomFactor:(CGFloat)f
{
    int i;

    zmFactor = f;
    for(i = 0; i < [controlPoints count]; i++)
        [[controlPoints objectAtIndex: i] setZoomFactor: zmFactor];

    [self remakePath];
}

- (BOOL)objectHitForSelection:(NSPoint)p
{
  return [self onPathBorder:p];
}

/** Returns yes if the Point lies on a control point */
- (BOOL)onControlPoint:(NSPoint)p
{
  NSInteger i;
  GRBezierControlPoint *cp;
  GRBezierHandle handle;

  for(i = 0; i < [controlPoints count]; i++)
    {
      cp = [controlPoints objectAtIndex: i];
      handle = [cp bzHandle];
      if(pointInRect(handle.centerRect, p))
	return YES;
    }

  return NO;
}

/** checks if a given point is a control point or a point on the path border

  ATTENTION: for closed path it retuns also YES if the point is inside the area
*/
- (BOOL)onPathBorder:(NSPoint)p
{
  if ([self onControlPoint:p])
    return YES;

  /* mypath represents the Path in the current zoom, so it needs to be converted */
  if([myPath containsPoint: GRpointZoom(p, zmFactor)])
    return YES;
  
  return NO;
}

- (GRBezierControlPoint *)firstPoint
{
    return (GRBezierControlPoint *)[controlPoints objectAtIndex: 0];
}



- (GRBezierControlPoint *)lastPoint
{
    return (GRBezierControlPoint *)[controlPoints objectAtIndex: [controlPoints count] -1];
}

- (NSUInteger)indexOfPoint:(GRBezierControlPoint *)aPoint
{
  NSUInteger i;
  NSUInteger r;
  BOOL found;

  r = NSNotFound;
  found = NO;

  i = 0;
  while (i < [controlPoints count] || !found)
    {
      if([controlPoints objectAtIndex: i] == aPoint)
        found = YES;
      i++;
    }

  if(found)
    r = i;
  
  return r;
}




/* override for editor handling */
- (void)setLocked:(BOOL)value
{
    [super setLocked:value];
    
    if(!locked)
        [editor unselect];
    else
        [(GRBezierPathEditor *)editor selectAsGroup];
}


- (void)draw
{
  GRBezierControlPoint *cp;
  NSUInteger i;
  NSBezierPath *bzp;
  CGFloat linew;
    
  if(![controlPoints count] || !visible)
    return;

  linew =  linewidth * zmFactor;

  bzp = [NSBezierPath bezierPath];
  if(filled)
    {
      [NSGraphicsContext saveGraphicsState];
      [fillColor set];
      [myPath fill];
      [NSGraphicsContext restoreGraphicsState];
    }
  if(stroked)
    {
      [NSGraphicsContext saveGraphicsState];
      [myPath setLineJoinStyle:linejoin];
      [myPath setLineCapStyle:linecap];
      [myPath setLineWidth:linew];
      [strokeColor set];
      [myPath stroke];
      [NSGraphicsContext restoreGraphicsState];
    }
    
    
  [bzp setLineWidth:1];
  if([(GRBezierPathEditor *)editor isGroupSelected])
    {
      for(i = 0; i < [controlPoints count]; i++)
        {
	  cp = [controlPoints objectAtIndex: i];
          [cp drawControlAsSelected:YES];
        }
    }
  
  if ([[NSGraphicsContext currentContext] isDrawingToScreen])
    [editor draw];
}

@end
