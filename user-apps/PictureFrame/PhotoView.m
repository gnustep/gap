/* PhotoView

Written: Adam Fedor <fedor@qwest.net>
Date: Nov 2007

*/
#import "PhotoView.h"
#import "PreferencesController.h"
#import "GNUstep.h"

#define dfltmgr [NSUserDefaults standardUserDefaults]

#ifndef GNUSTEP
@interface PhotoView (Private)
- (void) drawTransition: (NSAnimationProgress)progress;
@end

@implementation PhotoAnimation
- (void) setCurrentProgress: (NSAnimationProgress)progress
{
    [super setCurrentProgress: progress];
    [(PhotoView *)[self delegate] drawTransition: progress];
}
@end
#endif

@implementation PhotoView

- (id) initWithFrame: (NSRect)aFrame
{
  [super initWithFrame: aFrame];
  vertical = NO;
  transition = [dfltmgr floatForKey: DTransition];
  return self;
}

- (void) dealloc
{
  TEST_RELEASE(currentImage);
  TEST_RELEASE(lastImage);
#ifndef GNUSTEP
  RELEASE(animate);
#endif
  [super dealloc];
}

- (void) resetAnimation
{
#ifndef GNUSTEP
  int ttime, speed;
  if (animate)
    return;
  speed = [dfltmgr floatForKey: DSpeed];
  ttime = [dfltmgr floatForKey: DTransitionTime];
  if (ttime > speed/2)
    ttime = speed/2;
  if (ttime < 0.5)
    ttime = 0.5;
  animate = [[PhotoAnimation alloc] initWithDuration: ttime
                                    animationCurve: NSAnimationEaseOut];
  [animate setFrameRate: 30.0];
  [animate setDelegate: self];
#endif
}

- (void) setTransition: (photo_trans_t) newTransition
{
  transition = newTransition;
}

#ifndef GNUSTEP
- (void) setAnimation: (PhotoAnimation *)newAnimation
{
  ASSIGN(animate, newAnimation);
}
#endif

- (void) setImage: (NSImage *)newImage
{
  ASSIGN(lastImage, currentImage);
  ASSIGN(currentImage, newImage);
  [self resetAnimation];
#ifndef GNUSTEP
  [animate startAnimation];
#endif
}

- (NSRect) drawFrame: (NSRect)frame forImage: (NSImage *)image
{
  NSPoint pos;
  NSRect drawFrame, imageFrame;

  drawFrame = frame;
  imageFrame.size = [image size];
  pos = NSMakePoint(0, 0);
  if (vertical == NO && NSHeight(imageFrame) > NSWidth(imageFrame))
    {
      drawFrame.size.width = NSWidth(imageFrame) 
	* NSHeight(frame) / NSHeight(imageFrame);
      pos.x = (NSWidth(frame)  - NSWidth(imageFrame) 
		    * NSHeight(frame) / NSHeight(imageFrame)) / 2.0;
    }
  else if (vertical == YES && NSWidth(imageFrame) > NSHeight(imageFrame))
    {
      drawFrame.size.height = NSHeight(imageFrame) 
	* NSWidth(frame) / NSWidth(imageFrame);
      pos.y = (NSHeight(frame)  - NSHeight(imageFrame) 
		    * NSWidth(frame) / NSWidth(imageFrame)) / 2.0;
    }
#if 0
  if ([self isFlipped])
    {
      pos.y += NSHeight(frame);
    }
#endif
  drawFrame = NSMakeRect(pos.x, pos.y, 
			 NSWidth(drawFrame), NSHeight(drawFrame));
  return drawFrame;
}

#ifdef GNUSTEP
#define NSAnimationProgress int
#endif
- (void) drawTransition: (NSAnimationProgress)progress
{
  double fraction;
  NSRect frame, drawFrame, lastFrame;
  NSSize isize;
  if (currentImage == nil)
    return;

  if (progress > 1)
    progress = 1;
  frame = [self bounds];
  drawFrame = lastFrame = NSZeroRect;
  drawFrame = [self drawFrame: frame forImage: currentImage];
  if (lastImage)
    lastFrame = [self drawFrame: frame forImage: lastImage];

  switch (transition)
    {
    case TRANS_NONE:
      break;
    case TRANS_CROSSFADE:
      break;
    case TRANS_SLIDELEFT:
      break;
    case TRANS_SLIDERIGHT:
      break;
    case TRANS_SLIDETOP:
      break;
    case TRANS_SLIDEBOTTOM:
    default:
      break;
    }
      
  [[NSColor blackColor] set];
  NSRectFill(frame);
  if (progress < 1.0  && NSWidth(lastFrame))
    {
      isize = [lastImage size];
      [lastImage drawInRect: lastFrame
                  fromRect: NSMakeRect(0, 0, isize.width, isize.height)
                operation: NSCompositeSourceOver
                 fraction: 1.0];
    }
  isize = [currentImage size];
  fraction = (transition == TRANS_CROSSFADE) ? (progress) : 1;
  [currentImage drawInRect: drawFrame
                  fromRect: NSMakeRect(0, 0, isize.width, isize.height)
                operation: NSCompositeSourceOver
                 fraction: fraction];
  [[NSGraphicsContext currentContext] flushGraphics];
}

- (void) drawRect: (NSRect)rect
{
  [self drawTransition: 1.0];
}

@end

