// translated from the pswraps for GNUstep/MOSX by Gregory John Casamento

#import <AppKit/PSOperators.h>
#import <Foundation/NSUserDefaults.h>
#import "NSColorExtensions.h"

void drawArc2(double radius, double bdeg, double ddeg, double ldeg)
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

  // white circle...
  [idleColor set];
  PSmoveto(24,24);
  PSarc(24,24,radius,0,360);
  PSfill();

  // Light gray "pie" slice.
  [systemColor set]; 
  PSmoveto(24,24);
  PSarcn(24,24,radius,90,bdeg);
  PSfill();

  // Dark gray "pie" slice.
  [userColor set];
  PSmoveto(24,24);
  PSarcn(24,24,radius,bdeg,ddeg);
  PSfill();

  // Black slice.
  [niceColor set];
  PSmoveto(24,24);
  PSarcn(24,24,radius,ddeg,ldeg);
  PSfill();
}
