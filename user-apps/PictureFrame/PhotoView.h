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

@interface PhotoAnimation : NSAnimation
@end

@interface PhotoView : NSView
{
  NSImage *currentImage;
  NSImage *lastImage;
  PhotoAnimation *animate;
  photo_trans_t transition;
  BOOL vertical;
}

- (void) setTransition: (photo_trans_t) newTransition;
- (void) setAnimation: (PhotoAnimation *)newAnimation;
- (void) setImage: (NSImage *)newImage;

@end
