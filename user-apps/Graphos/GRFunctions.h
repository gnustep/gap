#import <Foundation/NSGeometry.h>


NSPoint pointApplyingCostrainerToPoint(NSPoint p, NSPoint sp);

/** returns if the point is inside the boundaries of the given rect */
BOOL pointInRect(NSRect rect, NSPoint p);

/** generates bounds from the coordinates and dimensions */
NSRect GRMakeBounds(float x, float y, float width, float height);

/** retuns the minimum of a and b */
double grmin(double a, double b);

/** returns the maximum of a and b */
double grmax(double a, double b);
