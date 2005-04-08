#include "Board.h"

#define BORDER_SIZE 30

@interface Board (Private)
- (void) _update;
@end

@implementation Board (Private)
- (void) _update
{
	/*
	if (_go == nil)
	{
		return;
	}

	NSRect bounds = [self bounds];
	float boardWidth;
	float cellWidth;
	int boardSize = [_go boardSize];
	StoneUI *stone;

	boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;
	boardSize = [_go boardSize];
	cellWidth = boardWidth / boardSize;

	stone = [StoneUI stoneWithColor:WhiteStone];

	ASSIGN(_stone, stone);
	*/
}

@end

@implementation Board

- (id) initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];

	[self setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(_update)
			   name:NSViewFrameDidChangeNotification
			 object:self];
	[self _update];

	return self;
}

- (id) initWithGo:(Go*)go
{
	[self initWithFrame:NSZeroRect];
	return self;
}

- (void) viewWillMoveToWindow: (NSWindow*)newWindow

{
	[super viewWillMoveToWindow:newWindow];
	[newWindow setAcceptsMouseMovedEvents:YES];
}

- (void) setGo:(Go *)go
{
	ASSIGN(_go, go);

	[self _update];
	[self setNeedsDisplay:YES];
}

- (void) setTileImage:(NSImage *)image
{
	ASSIGN(_woodTile, image);
}

- (void) mouseMoved:(NSEvent *)event
{
	mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
	[self setNeedsDisplay:YES];
}

- (void) mouseDown: (NSEvent*)theEvent
{
	[[self window] setAcceptsMouseMovedEvents:YES];
}

- (void) mouseEntered: (NSEvent*)theEvent
{
}

- (void) drawRect:(NSRect)r
{
	NSRect bounds = [self bounds];
	NSSize woodSize = [_woodTile size];
	float boardWidth;
	float cellWidth;
	int boardSize = [_go boardSize];
	float ir,ic;
	int i,j;

	boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;
	boardSize = [_go boardSize];
	cellWidth = boardWidth / boardSize;


	if (boardWidth < BORDER_SIZE)
	{
		return;
	}

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

	if (_go == nil)
	{
		return;
	}

	NSRect boardRect;
	boardRect = NSMakeRect((NSWidth(bounds) - boardWidth)/2,
			(NSHeight(bounds) - boardWidth)/2, boardWidth, boardWidth);

	[[NSColor colorWithCalibratedWhite:0.2
								 alpha:0.1] set];
	NSRectFill(boardRect);

	PSsetlinewidth(1);
	[[NSColor blackColor] set];

	ic = NSMinX(boardRect) + cellWidth/2 + cellWidth;
	ir = NSMinY(boardRect) + cellWidth/2 + cellWidth;

	for (i = 2; i <= boardSize-1; i++, ir+=cellWidth, ic+= cellWidth)
	{
		PSmoveto(ic, ir - ((i - 1) * cellWidth));
		PSrlineto(0, boardWidth - cellWidth);
		PSmoveto(ic - ((i - 1) * cellWidth), ir);
		PSrlineto(boardWidth - cellWidth, 0);
	}

	PSstroke();

	PSnewpath();
	PSsetlinewidth(2);
	PSmoveto(NSMinX(boardRect) + cellWidth/2, NSMinY(boardRect) + cellWidth/2);
	PSrlineto(boardWidth - cellWidth, 0);
	PSrlineto(0, boardWidth - cellWidth);
	PSrlineto(cellWidth - boardWidth, 0);
	PSclosepath();
	PSstroke();

	PSnewpath();
	ir = NSMinY(boardRect) + cellWidth/2 + cellWidth*3;
	for (i = 4; i <= boardSize; i+=6, ir+=cellWidth*6)
	{
		ic = NSMinX(boardRect) + cellWidth/2 + cellWidth*3;
		for (j = 4; j <= boardSize; j+=6, ic+=cellWidth*6)
		{
			PSmoveto(ic, ir);
			PSarc(ic, ir, BORDER_SIZE/10, 0, 360);
		}
	}
	PSfill();

	/* draw stones */

	for (i = 1; i <= boardSize; i ++)
	for (j = 1; j <= boardSize; j ++)
	{
		StoneUI *stone = [_go stoneAtLocation:MakeGoLocation(i,j)];
		if (stone != nil)
		{
			NSPoint p = NSMakePoint(NSMinX(boardRect) + (j * cellWidth) - (cellWidth * 0.5),NSMinY(boardRect) + (i * cellWidth) - (cellWidth * 0.5));
			[stone drawWithRadius:cellWidth/2
						  atPoint:p];
		}
	}

	PSmoveto(mousePoint.x + cellWidth/2, mousePoint.y);
	[[NSColor blackColor] set];
	PSsetalpha(0.2);
	PSarc(mousePoint.x, mousePoint.y, cellWidth/2, 0, 360);
	PSfill();

}
@end
