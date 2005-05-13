#include "PlayerCell.h"
#include "math.h"

@implementation PlayerCell

- (id) init
{
	[super init];
	[self setImagePosition:NSImageLeft];
	[self setButtonType:NSOnOffButton];
	_cell.is_bordered = NO;
	return self;
}

- (NSCellImagePosition) imagePosition
{
	return NSImageLeft;
}

- (void) setLeaf:(BOOL)q
{
	_isLeaf = q;
}

- (void) setLoaded:(BOOL)q
{
	_isLoad = q;
}

- (BOOL) isLoaded
{
	return _isLoad;
}

- (BOOL) isLeaf
{
	return _isLeaf;
}


- (void) drawInteriorWithFrame: (NSRect)r inView: (NSView*)controlView

{
	[super drawInteriorWithFrame:r
						  inView:controlView];

}

@end
