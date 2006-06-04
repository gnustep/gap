/* All Rights reserved */

#include <AppKit/AppKit.h>

@interface ImageBox : NSBox
{
	NSImage *_woodTile;
}
- (void) setTileImage:(NSImage *)image;
@end
