/* FrameView

	Written: Adam Fedor <fedor@qwest.net>
	Date: May 2007
*/
#import <Cocoa/Cocoa.h>

@protocol FrameView 

// animation methods...
- (void) oneStep;
- (void) reverseStep;
- (NSTimeInterval) animationDelayTime;

// inspector methods...
- (NSView *) inspector: (id)sender;
- (void) inspectorInstalled;
- (void) inspectorWillBeRemoved;

// window methods...
- (BOOL) useBufferedWindow;

// notification methods..
- (void) willEnterScreenSaverMode;
- (void) enteredScreenSaverMode;
- (void) willExitScreenSaverMode;

@end
