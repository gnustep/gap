// translated from the pswraps for GNUstep/MOSX by Gregory John Casamento

#ifdef GNUSTEP
#import <AppKit/PSOperators.h>
#endif

#import <Foundation/NSUserDefaults.h>
#import "NSColorExtensions.h"

#import "TimeMonWraps.h"

void drawArc2(double radius, double bdeg, double ddeg, double ldeg,
	      double mdeg)
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSColor *idleColor = [NSColor colorFromStringRepresentation: 
				  [defaults stringForKey: @"IdleColor"]];
  NSColor *niceColor = [NSColor colorFromStringRepresentation: 
				  [defaults stringForKey: @"NiceColor"]];
  NSColor *userColor = [NSColor colorFromStringRepresentation: 
				  [defaults stringForKey: @"UserColor"]];
  NSColor *systemColor = [NSColor colorFromStringRepresentation: 
				    [defaults stringForKey: @"SystemColor"]];
  NSColor *IOWaitColor = [NSColor colorFromStringRepresentation:
				    [defaults stringForKey: @"IOWaitColor"]];

  [idleColor set];
  PSmoveto(24,24);
  PSarc(24,24,radius,0,360);
  PSfill();

  [systemColor set]; 
  PSmoveto(24,24);
  PSarcn(24,24,radius,90,bdeg);
  PSfill();

  [userColor set];
  PSmoveto(24,24);
  PSarcn(24,24,radius,bdeg,ddeg);
  PSfill();

  [niceColor set];
  PSmoveto(24,24);
  PSarcn(24,24,radius,ddeg,ldeg);
  PSfill();

  [IOWaitColor set];
  PSmoveto(24,24);
  PSarcn(24,24,radius,ldeg,mdeg);
  PSfill();
}
