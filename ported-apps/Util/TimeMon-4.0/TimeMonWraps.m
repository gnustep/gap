// translated from the pswraps for GNUstep/MOSX by Gregory John Casamento

#include <AppKit/PSOperators.h>

// define the colors...
/*#define IDLE   PSsetrgbcolor(1.0,1.0,1.0)
#define NICE   PSsetrgbcolor(0.667,0.667,0.667)
#define USER   PSsetrgbcolor(0.333,0.333,0.333)
#define SYSTEM PSsetrgbcolor(0.0,0.0,0.0)*/
#define IDLE   PSsetrgbcolor(1.0,1.0,1.0)
#define NICE   PSsetrgbcolor(0.0,1.0,0.0)
#define USER   PSsetrgbcolor(0.0,0.0,1.0)
#define SYSTEM PSsetrgbcolor(1.0,0.0,0.0)

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

