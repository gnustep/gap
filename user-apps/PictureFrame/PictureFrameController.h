/* PictureFrameController

  Written: Adam Fedor <fedor@qwest.net>
  Date: May 2007
*/

#import <AppKit/AppKit.h>
#import "PictureWindow.h"
#import "OverlayView.h"
#import "FrameView.h"

@interface PictureFrameController : NSObject
{
  PictureWindow *pWindow;
  NSView<FrameView> *currentView;
  OverlayView *overlayView;
  id userInfoView;
  NSTimer *timer, *userTimer;
  NSTimeInterval runSpeed;
  int heatIndex;
  BOOL monitor;
}

- (IBAction)showPreferences:(id)sender;

- (void) createPictureWindow;
- (void) showOverlay;
- (void) removeOverlay;
- (void) startTimer;
- (void) stopTimer;
- (void) runAnimation: (NSTimer *)atimer;
@end
