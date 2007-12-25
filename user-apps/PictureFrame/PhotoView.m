/* PhotoView

Written: Adam Fedor <fedor@qwest.net>
Date: Nov 2007

*/
#import "PhotoView.h"
#import "PreferencesController.h"
#import "GNUstep.h"

#define dfltmgr [NSUserDefaults standardUserDefaults]

@implementation PhotoAnimation

@end

@implementation PhotoView

- (id) initWithFrame: (NSRect)aFrame
{
  [super initWithFrame: aFrame];
  vertical = NO;
  return self;
}

- (void) dealloc
{
  TEST_RELEASE(currentImage);
  TEST_RELEASE(lastImage);
  RELEASE(animate);
  [super dealloc];
}


- (void) setTransition: (photo_trans_t) newTransition
{
  transition = newTransition;
}

- (void) setAnimation: (PhotoAnimation *)newAnimation
{
  ASSIGN(animate, newAnimation);
}

- (void) setImage: (NSImage *)newImage
{
  ASSIGN(lastImage, currentImage);
  ASSIGN(currentImage, newImage);
  [self setNeedsDisplay: YES];
}

- (void) drawRect: (NSRect)rect
{
  NSRect frame = [self frame];
  NSRect drawFrame;
  NSPoint position;
  NSSize  imageSize;
  
  if (currentImage == nil)
    return;

  imageSize = [currentImage size];
  position = NSMakePoint(0, 0);
  drawFrame = frame;
  if (vertical == NO && imageSize.height > imageSize.width)
    {
      drawFrame.size.width = imageSize.width * NSHeight(frame) / imageSize.height;
      position.x = (NSWidth(frame)  - imageSize.width * NSHeight(frame) / imageSize.height) / 2.0;
    }
  else if (vertical == YES && imageSize.width > imageSize.height)
    {
      drawFrame.size.height = imageSize.height * NSWidth(frame) / imageSize.width;
      position.y = (NSHeight(frame)  - imageSize.height * NSWidth(frame) / imageSize.width) / 2.0;
    }
  if ([self isFlipped])
    {
      position.y += NSHeight(frame);
    }
  drawFrame = NSMakeRect(position.x, position.y, NSWidth(drawFrame), NSHeight(drawFrame));
  [currentImage drawInRect: drawFrame
                  fromRect: NSMakeRect(0, 0, imageSize.width, imageSize.height)
                operation: NSCompositeSourceOver
                 fraction: 1.0];
}

@end

