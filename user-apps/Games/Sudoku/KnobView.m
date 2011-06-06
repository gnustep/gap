
#import "KnobView.h"

@implementation KnobView


- (float)percent
{
    return percent;
}

- setPercent:(float)pval
{
    NSAssert(pval>=0.0 && pval<=100.0, @"not a percentage");
    percent = pval;
    return self;
}

- (void)drawRect:(NSRect)aRect
{
    NSRect frame = [self frame];
    float radius = frame.size.height/3.0;
    NSPoint center = {
        percent*frame.size.width/100.0, frame.size.height/2.0
    };
    
    [[NSColor whiteColor] set];
    PSrectfill(0, 0, frame.size.width, frame.size.height);

    [[NSColor blueColor] set];
    if(center.x<radius){
        center.x = radius;
    }
    else if(center.x>frame.size.width-radius){
        center.x = frame.size.width-radius;
    }
    PSarc(center.x, center.y, radius, 0, 360);
    PSfill();

    [[NSColor  blackColor] set];
    PSsetlinewidth(4);
    PSrectstroke(0, 0, frame.size.width, frame.size.height);
}


@end
