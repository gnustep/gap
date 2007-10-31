/* OverlayView

  Written: Adam Fedor <fedor@qwest.net>
  Date: May 2007
*/
#import <AppKit/NSView.h>
#import "ClockView.h"

@interface NSBezierPath(RoundedRectangle)

/**
Returns a closed bezier path describing a rectangle with curved
 corners The corner radius will be trimmed to not exceed half of the
 lesser rectangle dimension.  */
+ (NSBezierPath *) bezierPathWithRoundedRect: (NSRect) aRect cornerRadius: (double) radius;

@end


@interface OverlayView : NSView 
{
  NSTimer *timer;
  ClockView *clock;
  NSView *weatherView;
}

- (void) updateOverlay: sender;

@end
