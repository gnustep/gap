#import "GRFunctions.h"
#include <math.h>
#include <unistd.h>

#define GD_PI 3.14159265358979323846

NSPoint pointApplyingCostrainerToPoint(NSPoint p, NSPoint sp)
{
    float cos22 = cos(GD_PI * 22 / 180);
    float cos45 = cos(GD_PI * 45 / 180);
    float cos67 = cos(GD_PI * 67 / 180);
    double cy22, cy45, cy67, diffx, diffy;
    NSPoint cp;

    diffx = max(p.x, sp.x) - min(p.x, sp.x);
    diffy = max(p.y, sp.y) - min(p.y, sp.y);

    cy22 = diffx * pow(1 - pow(cos22, 2), 0.5) / cos22;
    cy45 = diffx * pow(1 - pow(cos45, 2), 0.5) / cos45;
    cy67 = diffx * pow(1 - pow(cos67, 2), 0.5) / cos67;

    if(diffy < cy45) {
        cp.x = p.x;
        if(diffy > cy22 && diffy < cy67)
        {
            if(p.y > sp.y)
                cp.y = sp.y + cy45;
            else
                cp.y = sp.y - cy45;
        } else
        {
            cp.y = sp.y;
        }
    } else {
        cp.x = sp.x;
        cp.y = p.y;
    }

    return cp;
}

BOOL pointInRect(NSRect rect, NSPoint p)
{
    if(p.x >= rect.origin.x
       && p.x <= (rect.origin.x + rect.size.width)
       && p.y >= rect.origin.y
       && p.y <= (rect.origin.y + rect.size.height))
        return YES;

    return NO;
}

double grmin(double a, double b) {
    if(a < b)
        return a;
    else
        return b;
}

double grmax(double a, double b) {
    if(a > b)
        return a;
    else
        return b;
}


