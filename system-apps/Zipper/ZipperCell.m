#import <AppKit/AppKit.h>
#import "ZipperCell.h"

@implementation ZipperCell : NSTextFieldCell

- (id) init
{
	self = [super initTextCell: @""];
//	[self setAlignment: NSLeftTextAlignment];
	return self;
}

/*
 * drawInteriorWithFrame is copied from NSCell.m and NSTextFieldCell.m
 * and modified to to display an image _and_ text.
 */
- (void) drawInteriorWithFrame: (NSRect)cellFrame inView: (NSView*)controlView
{
 	if (_textfieldcell_draws_background)
	{
		[_background_color set];
		NSRectFill ([self drawingRectForBounds: cellFrame]);
	}
	if (![controlView window])
	{
		return;
	}

	cellFrame = [self drawingRectForBounds: cellFrame];

	//FIXME: Check if this is also neccessary for images,
	// Add spacing between border and inside 
	if (_cell.is_bordered || _cell.is_bezeled)
	{
		cellFrame.origin.x += 3;
		cellFrame.size.width -= 6;
		cellFrame.origin.y += 1;
		cellFrame.size.height -= 2;
	}

	if (_cell_image)
	{
		NSSize size;
		NSPoint position;

		size = [_cell_image size];
		position.x = 0.;
		position.y = MAX(NSMidY(cellFrame) - (size.height/2.),0.);
		/*
		 * Images are always drawn with their bottom-left corner
		 * at the origin so we must adjust the position to take
		 * account of a flipped view.
		 */
		if ([controlView isFlipped])
			position.y += size.height;
		[_cell_image compositeToPoint: position operation: NSCompositeSourceOver];

		cellFrame.origin.x += size.width+3;
		cellFrame.size.width -= (size.width+3);
	}

	[self _drawAttributedText: [self attributedStringValue] inFrame: cellFrame];

	if (_cell.shows_first_responder)
	{
		NSDottedFrameRect(cellFrame);
	}
}

@end
