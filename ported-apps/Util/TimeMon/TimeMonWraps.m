// translated from the pswraps for GNUstep/MOSX by Gregory John Casamento

#include <AppKit/PSOperators.h>

// define the colors...
#define IDLE   PSsetrgbcolor(0.667,0.667,0.667) // gray
#define NICE   PSsetrgbcolor(0.000,0.000,1.000) // really blue
#define USER   PSsetrgbcolor(0.149,0.380,0.667) // turquoise
#define SYSTEM PSsetrgbcolor(0.321,0.494,0.784) // light blue

void drawArc2(double radius, double bdeg, double ddeg, double ldeg)
{
  // white circle...
  IDLE;
  PSmoveto(24,24);
  PSarc(24,24,radius,0,360);
  PSfill();

  // Light gray "pie" slice.
  SYSTEM;
  PSmoveto(24,24);
  PSarcn(24,24,radius,90,bdeg);
  PSfill();

  // Dark gray "pie" slice.
  USER;
  PSmoveto(24,24);
  PSarcn(24,24,radius,bdeg,ddeg);
  PSfill();

  // Black slice.
  NICE;
  PSmoveto(24,24);
  PSarcn(24,24,radius,ddeg,ldeg);
  PSfill();
}

