// translated from the pswraps for GNUstep/MOSX by Gregory John Casamento

#include <AppKit/PSOperators.h>

// define the colors...
#define IDLE   PSsetrgbcolor(1.0,1.0,1.0)
#define NICE   PSsetrgbcolor(0.667,0.667,0.667)
#define USER   PSsetrgbcolor(0.333,0.333,0.333)
#define SYSTEM PSsetrgbcolor(0.0,0.0,0.0)

void drawInit()
{
  // do nothing.
}

void PSWait()
{
  // do nothing.
}

void setColor(char *name, float r, float g, float b)
{
  // do nothing.
}

// the drawing functions...
void _doDrawArc1(double radius, double bdeg, double ddeg)
{
  // white circle...
  IDLE;
  PSmoveto(24,24);
  PSarc(24,24,radius,0,360);
  PSfill();
  PSstroke();

  // Dark gray "pie" slice.
  USER;
  PSmoveto(24,24);
  PSarcn(24,24,radius,90,4);
  PSfill();
  PSstroke();

  // Black slice.
  SYSTEM;
  PSmoveto(24,24);
  PSarcn(24,24,radius,90,4);
  PSfill();
  PSstroke();
}

void _doDrawArc2(double radius, double bdeg, double ddeg, double ldeg)
{
  // white circle...
  IDLE;
  PSmoveto(24,24);
  PSarc(24,24,radius,0,360);
  PSfill();
  PSstroke();

  // Light gray "pie" slice.
  NICE;
  PSmoveto(24,24);
  PSarcn(24,24,radius,90,4);
  PSfill();
  PSstroke();

  // Dark gray "pie" slice.
  USER;
  PSmoveto(24,24);
  PSarcn(24,24,radius,90,4);
  PSfill();
  PSstroke();

  // Black slice.
  SYSTEM;
  PSmoveto(24,24);
  PSarcn(24,24,radius,90,4);
  PSfill();
  PSstroke();
}

void drawArc1(double radius, double bdeg, double ddeg)
{
  _doDrawArc1(radius,bdeg,ddeg);
}

void drawArc2(double radius, double bdeg, double ddeg, double ldeg)
{
  _doDrawArc2(radius,bdeg,ddeg,ldeg);
}
