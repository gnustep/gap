// translated from the pswraps for GNUstep/MOSX by Gregory John Casamento

#include <AppKit/PSOperators.h>

// misc PS functions.
void drawInit();

void PSWait();

void setColor(char *n, float r, float g, float b);

// the drawing functions...
void _doDrawArc1(double radius, double bdeg, double ddeg);

void _doDrawArc2(double radius, double bdeg, double ddeg, double ldeg);

void drawArc1(double radius, double bdeg, double ddeg);

void drawArc2(double radius, double bdeg, double ddeg, double ldeg);

