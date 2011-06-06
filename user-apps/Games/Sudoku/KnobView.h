#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface KnobView : NSView
{
    float percent;
}

- (float)percent;
- setPercent:(float)pval;

- (void)drawRect:(NSRect)aRect;

@end
