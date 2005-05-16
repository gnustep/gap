#include "Board.h"
#include <Foundation/NSArray.h>

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

- (void) awakeFromNib
{
	[self setTileImage:[NSImage imageNamed:@"wood.jpg"]];
	[[self window] setAcceptsMouseMovedEvents:YES];
	isEditable = YES;
}

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (id) initWithFrame:(NSRect)frame
{
	NSArray *array = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",nil];
	ASSIGN(_verticalMarks, array);

	array = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",nil];
	ASSIGN(_horizontalMarks, array);

	ASSIGN(_shadow_stone, [StoneUI stoneWithColorType:EmptyPlayerType]);
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

- (void) dealloc
{
	NSLog(@"dealloc board %@",self);
	RELEASE(_go);
	RELEASE(_woodTile);

	RELEASE(_shadow_stone);

	[super dealloc];
	NSLog(@"done deboard");
}

- (id) initWithGo:(Go*)go
{
	[self initWithFrame:NSZeroRect];
	return self;
}

- (void) updateGlowArea:(GoLocation)loc
{
	if (loc.row == 0)
	{
		return;
	}

	NSRect bounds = [self bounds];
	float boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;
	int boardSize = [_go boardSize];
	float cellWidth = boardWidth / boardSize;
	NSRect r;

	r.size.width = cellWidth * 2;
	r.size.height = cellWidth * 2;
	r.origin = [self pointForGoLocation:lastLocation];
	r.origin.x -= cellWidth;
	r.origin.y -= cellWidth;
	[self setNeedsDisplayInRect:r];
}

- (void) stoneAdded:(NSNotification *)notification
{
	NSDictionary *dict = [notification userInfo];
	id <Stone> aStone;
	if (lastLocation.row != 0)
	{
		[self updateGlowArea:lastLocation];
	}

	if (dict == nil)
	{
		lastLocation = GoNoLocation;
	}
	else
	{
		aStone = [dict objectForKey:@"Stone"];
		if (aStone != nil)
		{
			lastLocation = [aStone location];
		}
		else
		{
			lastLocation = GoNoLocation;
		}
	}

	[self updateGlowArea:lastLocation];
	lialpha = 0.1;

	[liTimer invalidate];

	liTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
											   target:self
											 selector:@selector(_addLight)
											 userInfo:nil
											  repeats:YES];

}

- (void) _addLight
{
	lialpha *= 1.2;
	if (lialpha > 1.0)
	{
		lialpha = 1.0;
		[liTimer invalidate];
		liTimer = nil;
	}
	[self updateGlowArea:lastLocation];
}

- (void) viewWillMoveToWindow: (NSWindow*)newWindow

{
	[super viewWillMoveToWindow:newWindow];
	[newWindow setAcceptsMouseMovedEvents:YES];
}

- (void) setEditable:(BOOL)editable
{
	isEditable = editable;
	[self setNeedsDisplay:YES];
}

- (void) setGo:(Go *)go
{
	ASSIGN(_go, go);
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(stoneAdded:)
			   name:GoStoneNotification
			 object:_go];

	[_go setStoneClass:[StoneUI class]];


	[self _update];
	[self setNeedsDisplay:YES];

}

- (void) setTileImage:(NSImage *)image
{
	ASSIGN(_woodTile, image);
}

- (void) mouseMoved:(NSEvent *)event
{
	GoLocation newLoc = [self goLocationForPoint:[self convertPoint:[event locationInWindow] fromView:nil]];

	NSRect updateRect;
	NSRect bounds = [self bounds];
	float boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;
	int boardSize = [_go boardSize];
	float cellWidth = boardWidth / boardSize;
	NSRect boardRect = NSMakeRect((NSWidth(bounds) - boardWidth)/2,
			(NSHeight(bounds) - boardWidth)/2, boardWidth, boardWidth);

	updateRect = NSMakeRect(NSMinX(boardRect) + (mouseLocation.column * cellWidth) - cellWidth, NSMinY(boardRect) + (mouseLocation.row * cellWidth) - cellWidth, cellWidth, cellWidth);
	[self setNeedsDisplayInRect:updateRect];

	mouseLocation = newLoc;

	updateRect = NSMakeRect(NSMinX(boardRect) + (mouseLocation.column * cellWidth) - cellWidth, NSMinY(boardRect) + (mouseLocation.row * cellWidth) - cellWidth, cellWidth, cellWidth);
	[self setNeedsDisplayInRect:updateRect];

	NSPoint p1 = [self convertPoint:[event locationInWindow] fromView:nil];
	NSPoint p2 = [self pointForGoLocation:mouseLocation];

	shalpha = ((cellWidth/3) - sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y)))/(cellWidth/3);

	if (shalpha < 0)
	{
		shalpha = 0;
	}

}

- (void) mouseDown: (NSEvent*)event
{
	if (isEditable == NO)
	{
		return;
	}

	GoLocation downLoc = [self goLocationForPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
	if ([_go stoneAtLocation:downLoc] == nil)
	{
		[__owner playerShouldPutStoneAtLocation:downLoc];
	}
}

- (void) drawRect:(NSRect)r
{
	NSGraphicsContext *ctxt=GSCurrentContext();

	NSRect bounds = [self bounds];
	NSSize woodSize = [_woodTile size];
	float boardWidth;
	float cellWidth;
	int boardSize = [_go boardSize];
	NSRect boardRect;
	float ir,ic;
	int i,j;
	float k;
	NSEnumerator *en;
	NSFont *aFont;

	boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;
	boardSize = [_go boardSize];
	cellWidth = boardWidth / boardSize;


	if (boardWidth < BORDER_SIZE)
	{
		return;
	}

	/* fill the wood tile */
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

	boardRect = NSMakeRect((NSWidth(bounds) - boardWidth)/2,
			(NSHeight(bounds) - boardWidth)/2, boardWidth, boardWidth);

	[[NSColor colorWithCalibratedRed:0.3
							   green:0.0
								blue:0.1
							   alpha:0.1] set];
	NSRectFill(boardRect);

	DPSsetlinewidth(ctxt, 1);
	[[NSColor blackColor] set];

	ic = NSMinX(boardRect) + cellWidth/2 + cellWidth;
	ir = NSMinY(boardRect) + cellWidth/2 + cellWidth;

	for (i = 2; i <= boardSize-1; i++, ir+=cellWidth, ic+= cellWidth)
	{
		DPSmoveto(ctxt, ic, ir - ((i - 1) * cellWidth));
		DPSrlineto(ctxt, 0, boardWidth - cellWidth);
		DPSmoveto(ctxt, ic - ((i - 1) * cellWidth), ir);
		DPSrlineto(ctxt, boardWidth - cellWidth, 0);
	}


	DPSstroke(ctxt);

	DPSnewpath(ctxt);
	DPSsetlinewidth(ctxt, 2);
	DPSmoveto(ctxt, NSMinX(boardRect) + cellWidth/2, NSMinY(boardRect) + cellWidth/2);
	DPSrlineto(ctxt, boardWidth - cellWidth, 0);
	DPSrlineto(ctxt, 0, boardWidth - cellWidth);
	DPSrlineto(ctxt, cellWidth - boardWidth, 0);
	DPSclosepath(ctxt);
	DPSstroke(ctxt);

	/* draw spots */
	if (cellWidth > 10)
	{
		DPSnewpath(ctxt);
		ir = NSMinY(boardRect) + cellWidth/2 + cellWidth*3;
		for (i = 4; i <= boardSize; i+=6, ir+=cellWidth*6)
		{
			ic = NSMinX(boardRect) + cellWidth/2 + cellWidth*3;
			for (j = 4; j <= boardSize; j+=6, ic+=cellWidth*6)
			{
				DPSmoveto(ctxt,ic, ir);
				DPSarc(ctxt,ic, ir, BORDER_SIZE/10, 0, 360);
			}
		}
		DPSfill(ctxt);
	}

	/* draw text mark */
	float fontSize;
	fontSize = cellWidth/2;
	if (fontSize >= 7)
	{
		aFont = [NSFont boldSystemFontOfSize:fontSize];

		ic = NSMinX(boardRect) + cellWidth/2;
		ir = NSMinY(boardRect) + cellWidth/2;

		for (i = 0; i < boardSize; i++, ir+=cellWidth, ic+= cellWidth)
		{
			NSSize strSize;
			NSString *str = [_horizontalMarks objectAtIndex:i];
			NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
			[attrStr addAttribute:NSFontAttributeName
							value:aFont
							range:NSMakeRange(0,[attrStr length])];
			[attrStr addAttribute:NSForegroundColorAttributeName
							value:[NSColor blackColor]
							range:NSMakeRange(0,[attrStr length])];
			strSize = [attrStr size];
			[attrStr drawAtPoint:NSMakePoint(ic - strSize.width/2, NSMaxY(boardRect))];
			[attrStr drawAtPoint:NSMakePoint(ic - strSize.width/2, NSMinY(boardRect) - strSize.height)];
			RELEASE(attrStr);

			str = [_verticalMarks objectAtIndex:i];
			attrStr = [[NSMutableAttributedString alloc] initWithString:str];
			[attrStr addAttribute:NSFontAttributeName
							value:aFont
							range:NSMakeRange(0,[attrStr length])];
			[attrStr addAttribute:NSForegroundColorAttributeName
							value:[NSColor blackColor]
							range:NSMakeRange(0,[attrStr length])];
			strSize = [attrStr size];
			[attrStr drawAtPoint:NSMakePoint(NSMaxX(boardRect),ir - strSize.height/2)];
			[attrStr drawAtPoint:NSMakePoint(NSMinX(boardRect) - strSize.width,ir - strSize.height/2)];
			RELEASE(attrStr);

		}
	}

	/* draw stones */

	/* first round, draw shadow and indicator */
	for (i = 1; i <= boardSize; i ++)
	for (j = 1; j <= boardSize; j ++)
	{
		StoneUI *stone = [_go stoneAtLocation:MakeGoLocation(i,j)];
		if (stone != nil)
		{
			NSPoint p = NSMakePoint(NSMinX(boardRect) + (j * cellWidth) - (cellWidth * 0.5),NSMinY(boardRect) + (i * cellWidth) - (cellWidth * 0.5));

			if (lastLocation.row == i && lastLocation.column == j)
			{
				[stone drawIndicatorWithRadius:cellWidth/2
									   atPoint:p
										 alpha:lialpha];
			}
		}
		else if (mouseLocation.row == i && mouseLocation.column == j && isEditable)
		{
			NSPoint p = [self pointForGoLocation:mouseLocation];
			/*
			[_shadow_stone drawWithRadius:cellWidth/2
								  atPoint:p];
								  */
			for (k = cellWidth/2; k > 0; k = k - 1.0)
			{
				DPSgsave(ctxt);
				DPSnewpath(ctxt);
				DPSsetalpha(ctxt,shalpha * (cellWidth/2 - k)/(cellWidth/2));
				DPSarc(ctxt,p.x,p.y,k,0,360);
				DPSarcn(ctxt,p.x,p.y,k-1.0,360,0);
				DPSfill(ctxt);
				DPSgrestore(ctxt);
			}
		}
	}

	/* second round, draw stones */

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


}

- (NSRect) rectForGoLocation:(GoLocation)loc
{
	NSRect boardRect;
	NSRect bounds = [self bounds];
	float boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;
	int boardSize = [_go boardSize];
	float cellWidth = boardWidth / boardSize;

	boardRect = NSMakeRect((NSWidth(bounds) - boardWidth)/2,
			(NSHeight(bounds) - boardWidth)/2, boardWidth, boardWidth);

	NSRect retRect;
	retRect.origin = [self pointForGoLocation:loc];
	retRect.size = NSZeroSize;
	retRect = NSInsetRect(retRect,-cellWidth/2, -cellWidth/2);
	return retRect;
}

- (NSPoint) pointForGoLocation:(GoLocation)loc
{
	NSRect boardRect;
	NSRect bounds = [self bounds];
	float boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;
	int boardSize = [_go boardSize];
	float cellWidth = boardWidth / boardSize;
	NSPoint retpnt;

	boardRect = NSMakeRect((NSWidth(bounds) - boardWidth)/2,
			(NSHeight(bounds) - boardWidth)/2, boardWidth, boardWidth);

	retpnt.x = (loc.column - 1) * cellWidth + NSMinX(boardRect) + cellWidth/2;
	retpnt.y = (loc.row - 1) * cellWidth + NSMinY(boardRect) + cellWidth/2;

	return retpnt;
}

- (GoLocation) goLocationForPoint:(NSPoint)p
{
	NSRect boardRect;
	NSRect bounds = [self bounds];
	float boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;
	int boardSize = [_go boardSize];
	float cellWidth = boardWidth / boardSize;
	GoLocation retloc;

	boardRect = NSMakeRect((NSWidth(bounds) - boardWidth)/2,
			(NSHeight(bounds) - boardWidth)/2, boardWidth, boardWidth);

	retloc.column = (p.x - NSMinX(boardRect))/cellWidth + 1;
	retloc.row = (p.y - NSMinY(boardRect))/cellWidth + 1;

	return retloc;
}

- (Go *) go
{
	return _go;
}

- (void) setOwner:(id <BoardOwner>)owner
{
	__owner = owner;
}
@end
