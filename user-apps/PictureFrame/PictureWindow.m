/* PictureWindow

  Written: Adam Fedor <fedor@qwest.net>
  Date: May 2007
*/
#import "PictureWindow.h"

@implementation PictureWindow

- (BOOL) canBecomeKeyWindow
{
  return YES;
}

- (BOOL) canBecomeMainWindow
{
  return YES;
}

- (void) hide: (id)sender
{
  // Don't react to hide.  This window cannot be hidden.
}

- (void) keyDown: (NSEvent*)theEvent
{
  /* Let the delegate handle it */
  [[self delegate] keyDown: theEvent];
}

@end
