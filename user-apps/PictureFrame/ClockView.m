// ClockView.m -- screensaver view that shows an analog clock
// Mac OS X port Copyright (C) 2006 Michael Schmidt <no.more.spam@gmx.net>.
//
// ClockSaver is derived from the KDE screensaver module KClock.
// KDE's KClock is Copyright (C) 2003 Melchior Franz <mfranz@kde.org>.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License Version 2 as
// published by the Free Software Foundation.
#import "ClockView.h"

#ifndef MIN
#define MIN(a,b)  (((a) < (b)) ? a : b)
#endif

#define COLOR(N)  ((NSColor*)[NSUnarchiver unarchiveObjectWithData: [defaults objectForKey: N]])

// screensaver defaults
static NSArray *defKeys = nil;
static NSArray *defObjs = nil;

@interface ClockView (private)
// drawing primitives
- (void)computeBaseTransformForFrame:(NSRect)frame;
- (void)drawRadialAtAngle:(float)alpha r0:(float)r0 r1:(float)r1 width:(float)width;
- (void)drawDiscWithRadius:(float)radius;
- (void)drawHandAtAngle:(float)angle length:(float)length width:(float)width color:(NSColor*)color disc:(BOOL)disc;
- (void)drawScale;
@end

@implementation ClockView

// class initialization
+ (void)initialize
{
  // all defaults keys
  if (defKeys == nil)
    defKeys = [[NSArray arrayWithObjects:
                  @"hourColor",        
                  @"minuteColor",         
                  @"secondColor",      
                  @"scaleColor",          
                  @"shadowColor",          
                  @"backgroundColor",          
                  @"scaleSize",      
                  @"showSecondHand",
                  @"transparency",
                  nil] retain];
  
  // fallback values for all defaults
  if (defObjs == nil)
    defObjs = [[NSArray arrayWithObjects:
                  [NSArchiver archivedDataWithRootObject: [NSColor whiteColor]],
                  [NSArchiver archivedDataWithRootObject: [NSColor whiteColor]],
                  [NSArchiver archivedDataWithRootObject: [NSColor redColor]],
                  [NSArchiver archivedDataWithRootObject: [NSColor whiteColor]],
                  [NSArchiver archivedDataWithRootObject: [NSColor grayColor]],
                  [NSArchiver archivedDataWithRootObject: [NSColor blackColor]],
                  [NSNumber numberWithFloat: 0.95],
                  [NSNumber numberWithBool: NO],
                  [NSNumber numberWithFloat: 0.0],              
                  nil] retain];
  

}


- (id)initWithFrame: (NSRect)frame
{
  defaults = [NSDictionary dictionaryWithObjects: defObjs forKeys: defKeys];
  [defaults retain];
  baseTransform  = nil;
  [self computeBaseTransformForFrame: frame];
  
  return self;
}

- (void) setFrame: (NSRect)frame
{
  //[super setFrame: frame];
  [self computeBaseTransformForFrame: frame];
}

//
// drawing routines
//
// basic transformation matrix for drawing operations
- (void)computeBaseTransformForFrame:(NSRect)frame
{
  [baseTransform release];
  baseTransform = [[NSAffineTransform transform] retain];

  // move square of clock area to center of view
  float minSize = MIN (frame.size.width, frame.size.height);
  
  // Translate, since we are not a real view 
  [baseTransform translateXBy: NSMinX(frame) yBy: NSMinY(frame)];

  [baseTransform translateXBy: (frame.size.width  - minSize) / 2.0
                          yBy: (frame.size.height - minSize) / 2.0];

  // scale to width/height of 2000
  [baseTransform scaleXBy: minSize / 2000.0
                      yBy: minSize / 2000.0];

  // origin is in center of screen
  [baseTransform translateXBy: 1000.0
                          yBy: 1000.0];
}


- (void)animateOneFrame
{
  NSCalendarDate *now = [NSCalendarDate calendarDate];
  // draw clock
  [self drawScale];
  
  [self drawHandAtAngle: ([now hourOfDay] % 12) * 30.0 + [now minuteOfHour] * 0.5
                 length: 600.0
                  width: 55.0
                  color: COLOR(@"hourColor")
                   disc: NO];
  
  [self drawHandAtAngle: [now minuteOfHour] * 6.0 + [now secondOfMinute] * 0.1
                 length: 900.0
                  width: 40.0
                  color: COLOR(@"minuteColor")
                   disc: YES];
  
  if ([[defaults objectForKey:@"showSecondHand"] boolValue])
    [self drawHandAtAngle: [now secondOfMinute] * 6.0
                   length: 900.0
                    width: 30.0
                    color: COLOR(@"secondColor")
                     disc: YES];
}


// draws a radial line segment (clock hands and scale)
- (void)drawRadialAtAngle:(float)alpha r0:(float)r0 r1:(float)r1 width:(float)width
{
  // transform screen coordinates
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform appendTransform:baseTransform];
  [transform rotateByDegrees: 90-alpha];

  // draw a line
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  NSBezierPath *path         = [NSBezierPath bezierPath];
  
  [context saveGraphicsState];
  [transform concat];

  [path setLineWidth: width];
  [path moveToPoint: NSMakePoint (r0, 0.0)];
  [path lineToPoint: NSMakePoint (r1, 0.0)];
  [path stroke];

  [context restoreGraphicsState];
}


// draws a circle located at the origin (part of minuts and second hand)
- (void)drawDiscWithRadius:(float)radius
{
  // transform screen coordinates
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform appendTransform:baseTransform];

  // draw a circle
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  NSBezierPath *path         = [NSBezierPath bezierPath];
  
  [context saveGraphicsState];
  [transform concat];
  
  [path appendBezierPathWithArcWithCenter: NSZeroPoint
                                   radius: radius
                               startAngle: 0.0
                                 endAngle: 360.0];
  [path fill];
  
  [context restoreGraphicsState];
}


// draws a clock hand with certain attributes
- (void)drawHandAtAngle: (float)angle
                 length: (float)length
                  width: (float)width
                  color: (NSColor*)color
                   disc: (BOOL)disc
{
  float shadowWidth = 1.0;
  
  // draw shadow for hand
  [COLOR(@"shadowColor") set];
  
  if (disc)
    [self drawDiscWithRadius: width * 1.3 + shadowWidth];
  
  [self drawRadialAtAngle: angle
                       r0: 0.75 * width
                       r1: length + shadowWidth
                    width: width  + shadowWidth];
  
  // draw hand itself
  [color set];
  
  if (disc)
    [self drawDiscWithRadius: width * 1.3];
  
  [self drawRadialAtAngle: angle
                       r0: 0.75 * width
                       r1: length
                    width: width];
}


// draws the clock scale
- (void)drawScale
{
  [COLOR(@"scaleColor") set];
  int angle;
  
  // for each minute...
  for (angle = 0; angle < 360; angle += 6)
    {
      if (angle % 30)
        [self drawRadialAtAngle: angle
                             r0: 920.0
                             r1: 980.0
                          width: 15.0];
      else
        [self drawRadialAtAngle: angle
                             r0: 825.0
                             r1: 980.0
                          width: 40.0];
    }
}

@end

// eof
