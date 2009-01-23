/* FrameDisplay

	Written: Adam Fedor <fedor@qwest.net>
	Date: May 2007
*/
#import <Cocoa/Cocoa.h>

@protocol FrameDisplay <NSObject>

- initWithFrame: (NSRect) frame;
- (void) setVerbose: (int)state;
- (NSView *) displayView;

// animation methods...
- (NSString *) nextPhoto;
- (void) oneStep;
- (void) reverseStep;
- (NSTimeInterval) animationDelayTime;

// inspector methods...
- (NSView *) preferenceView;

@end
