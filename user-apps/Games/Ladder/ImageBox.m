/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "ImageBox.h"

@implementation ImageBox
- (void) awakeFromNib
{
	[self setTileImage:AUTORELEASE([[NSImage alloc] initWithContentsOfFile:@"wood.jpg"])];
}

- (void) setTileImage:(NSImage *)image
{
	ASSIGN(_woodTile, image);
}

- (void) drawRect:(NSRect)r
{
	float ir,ic;
	NSRect bounds = [self bounds];
	NSSize woodSize = [_woodTile size];

	if (_woodTile)
	{
		for (ir = 0; ir < NSMaxY(bounds); ir += woodSize.height)
		{
			for (ic = 0; ic < NSMaxX(bounds); ic += woodSize.width)
			{
				[_woodTile compositeToPoint:NSMakePoint(ic, ir)
								   operation:NSCompositeSourceOver];
			}
		}
	}
	else
	{
		[[NSColor orangeColor] set];
		NSRectFill(bounds);
	}
}

@end
