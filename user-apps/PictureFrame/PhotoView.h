/* PhotoView

	Written: Adam Fedor <fedor@qwest.net>
	Date: Nov 2007
*/
#include <AppKit/AppKit.h>

typedef enum {
  TRANS_NONE,
  TRANS_CROSSFADE,
  TRANS_SLIDELEFT,
  TRANS_SLIDERIGHT,
  TRANS_SLIDETOP,
  TRANS_SLIDEBOTTOM,
  TRANS_RANDOM,
  TRANS_LAST
} photo_trans_t;

#ifndef GNUSTEP
@interface PhotoAnimation : NSAnimation
@end
#endif

@interface PhotoView : NSView
{
  NSImage *currentImage;
  NSImage *lastImage;
#ifndef GNUSTEP
  PhotoAnimation *animate;
#endif
  photo_trans_t transition;
  BOOL vertical;
}

- (void) setTransition: (photo_trans_t) newTransition;
#ifndef GNUSTEP
- (void) setAnimation: (PhotoAnimation *)newAnimation;
#endif
- (void) setImage: (NSImage *)newImage;

@end
