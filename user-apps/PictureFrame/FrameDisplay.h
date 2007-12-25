/* FrameDisplay

	Written: Adam Fedor <fedor@qwest.net>
	Date: May 2007
*/
#import <Cocoa/Cocoa.h>

@protocol FrameDisplay <NSObject>

- initWithFrame: (NSRect) frame;
- (NSView *) displayView;

// animation methods...
- (void) oneStep;
- (void) reverseStep;
- (NSTimeInterval) animationDelayTime;

// inspector methods...
- (NSView *) preferenceView;

@end
