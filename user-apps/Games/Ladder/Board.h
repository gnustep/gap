#include <AppKit/AppKit.h>
#include "StoneUI.h"

@interface Board : NSView
{
	Go *_go;
	NSImage *_woodTile;
}

- (id) initWithGo:(Go *)go;
- (void) setGo:(Go *)go;
- (void) setTileImage:(NSImage *)image;
@end
