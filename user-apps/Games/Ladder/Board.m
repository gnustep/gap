#include "Board.h"
#include <Foundation/NSArray.h>

#define BORDER_SIZE 30

@interface Board (Private)
- (void) _update;
- (void) updateGlowArea:(GoLocation)loc;
- (NSRect) rectForGoLocation:(GoLocation)loc;
@end

@interface SpotLight : NSObject
{
@public
	GoLocation location;
	float alpha;
	BOOL shouldDecrease;
}

+ (SpotLight *) spotLightWithLocation:(GoLocation)loc;
@end
@implementation SpotLight
+ (SpotLight *) spotLightWithLocation:(GoLocation)loc
{
	SpotLight *sp = [[self alloc] init];
	sp->location = loc;
	return AUTORELEASE(sp);
}

@end

@implementation Board (Private)
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
	r.origin = [self pointForGoLocation:loc];
	r.origin.x -= cellWidth;
	r.origin.y -= cellWidth;
	[self setNeedsDisplayInRect:r];
}

- (void) _update
{
	bounds = [self bounds];
	boardWidth =  MIN(NSWidth(bounds),NSHeight(bounds)) - BORDER_SIZE * 2;

	if (_go != nil)
	{
		boardSize = [_go boardSize];
		cellWidth = boardWidth / boardSize;
	}

	boardRect = NSMakeRect((NSWidth(bounds) - boardWidth)/2,
			(NSHeight(bounds) - boardWidth)/2, boardWidth, boardWidth);
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

- (BOOL) acceptsFirstMouse: (NSEvent*)theEvent
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
	ASSIGN(_lastStones, [NSMutableArray array]);
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
	NSLog(@"dealloc board %@ %p",self,liTimer);
	[liTimer invalidate];
	liTimer = nil;
	__lastStone = nil;
	DESTROY(_lastStones);

	DESTROY(_go);
	DESTROY(_woodTile);

	DESTROY(_shadow_stone);

	[super dealloc];
	NSLog(@"done deboard");
	fprintf(stderr,"done %p\n",self);
}

- (id) initWithGo:(Go*)go
{
	[self initWithFrame:NSZeroRect];
	return self;
}

- (void) stoneAdded:(NSNotification *)notification
{
	NSDictionary *dict = [notification userInfo];
	id <Stone> aStone;
	NSLog(@"here");

	[self setNeedsDisplay:YES];

	if (dict != nil)
	{
		aStone = [dict objectForKey:@"Stone"];
		if (aStone != nil)
		{
			__lastStone = [SpotLight spotLightWithLocation:[aStone location]];
			[_lastStones addObject:__lastStone];
		}
	}

	[liTimer invalidate];

	liTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
											   target:self
											 selector:@selector(_adjustLight)
											 userInfo:nil
											  repeats:YES];

}

- (void) shouldPass:(NSNotification *)notification
{
	if (isEditable == NO)
	{
		return;
	}

	[__owner playerShouldPutStoneAtLocation:GoNoLocation];
	__lastStone = nil;
	[liTimer invalidate];

	if ([_lastStones count] > 0)
	{
		liTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
												   target:self
												 selector:@selector(_adjustLight)
												 userInfo:nil
												  repeats:YES];
	}
	else
	{
		liTimer = nil;
	}
}

/* dimming light */
- (void) _adjustLight
{
	int n = [_lastStones count];
	SpotLight *spots[n];

	if (n == 0 || (n == 1 && __lastStone && ((SpotLight *)__lastStone)->alpha > 1.0))
	{
		[liTimer invalidate];
		liTimer = nil;
	}

	if (_lastStones == nil)
	{
		return;
	}

	[_lastStones getObjects:spots];
	while (n)
	{
		n--;
		[self updateGlowArea:spots[n]->location];

		if (spots[n]->shouldDecrease && spots[n] != __lastStone)
//		if (spots[n] != __lastStone)
		{
			spots[n]->alpha = spots[n]->alpha - 0.1;
			if (spots[n]->alpha < 0)
			{
				[_lastStones removeObject:spots[n]];
			}
		}
		else if (spots[n]->alpha < 1.0)
		{
			spots[n]->alpha = spots[n]->alpha + 0.1;
			if (spots[n]->alpha > 1.0)
			{
				spots[n]->shouldDecrease = YES;
			}
		}

	}

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

- (void) setShowHistory:(BOOL)show
{
	showHistory = show;
	[self setNeedsDisplay:YES];
}

- (void) setGo:(Go *)go
{
	if (_go != nil)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:nil
													  object:_go];
	}

	ASSIGN(_go, go);
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(stoneAdded:)
			   name:GoStoneNotification
			 object:_go];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(shouldPass:)
			   name:GameHelperSuggestionNotification
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
	if (_go == nil)
	{
		return;
	}

	GoLocation newLoc = [self goLocationForPoint:[self convertPoint:[event locationInWindow] fromView:nil]];

	NSRect updateRect;

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
	if (_go == nil)
	{
		return;
	}

	GoLocation downLoc = [self goLocationForPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
	unsigned int boardSize = [_go boardSize];

	if (isEditable == NO || downLoc.row == 0 || downLoc.column == 0 ||
			downLoc.row > boardSize || downLoc.column > boardSize)
	{
		return;
	}

	if ([_go stoneAtLocation:downLoc] == nil)
	{
		[__owner playerShouldPutStoneAtLocation:downLoc];
	}
}

#define MINFONTSIZE 6
- (void) drawRect:(NSRect)r
{
	NSGraphicsContext *ctxt=GSCurrentContext();

	NSSize woodSize = [_woodTile size];
	float ir,ic;
	int i,j;
	float k;
	NSEnumerator *en;
	NSFont *aFont;

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

	if (_go == nil || boardWidth < BORDER_SIZE)
	{
		return;
	}

	[[NSColor colorWithCalibratedRed:0.3
							   green:0.0
								blue:0.1
							   alpha:0.1] set];
	NSRectFill(boardRect);

	DPSsetlinewidth(ctxt, 1);
	[[NSColor blackColor] set];

	cellWidth = boardWidth / boardSize;

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
	/* FIXME scale spot */
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
	if (fontSize > 20)
	{
		fontSize = 20;
	}

	if (fontSize >= MINFONTSIZE)
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

	/* draw shadow */
	if (isEditable && mouseLocation.row > 0 &&
			mouseLocation.row <= boardSize && mouseLocation.column <= boardSize)
	{
		/* fixme : change this to check if legal */
		StoneUI *stone = [_go stoneAtLocation:mouseLocation];
		if (stone == nil)
		{
			NSPoint p = [self pointForGoLocation:mouseLocation];
			/* //old code
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

	/* draw spot light */
	if ([_lastStones count] > 0)
	{
		SpotLight *spot;

		en = [_lastStones objectEnumerator];

		while ((spot = [en nextObject]))
		{
			/* FIXME */
			[_shadow_stone drawIndicatorWithRadius:cellWidth/2
										   atPoint:[self pointForGoLocation:spot->location]
											 alpha:spot->alpha > 1.0?1.0:spot->alpha];
		}
	}

	/* draw stones */

	fontSize *= 0.7;

	if (fontSize >= MINFONTSIZE)
	{
		aFont = [NSFont systemFontOfSize:fontSize];
	}
	else
	{
		aFont = nil;
	}

	for (i = 1; i <= boardSize; i ++)
	for (j = 1; j <= boardSize; j ++)
	{
		GoLocation l = MakeGoLocation(i,j);
		StoneUI *stone = [_go stoneAtLocation:l];
		if (stone != nil)
		{
			NSPoint p = NSMakePoint(NSMinX(boardRect) + (j * cellWidth) - (cellWidth * 0.5),NSMinY(boardRect) + (i * cellWidth) - (cellWidth * 0.5));

			[stone drawWithRadius:cellWidth/2
						  atPoint:p];
			if (showHistory && aFont != nil && NSIntersectsRect([self rectForGoLocation:l],r))
			{
				NSSize strSize;
				p = [self pointForGoLocation:l];
				NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d",[stone turnNumber]]];
				[attrStr addAttribute:NSFontAttributeName
								value:aFont
								range:NSMakeRange(0,[attrStr length])];
				[attrStr addAttribute:NSForegroundColorAttributeName
								value:[stone colorType]==BlackPlayerType?[NSColor lightGrayColor]:[NSColor darkGrayColor]
								range:NSMakeRange(0,[attrStr length])];
				strSize = [attrStr size];
				[stone centerAttributedString:attrStr
									  toPoint:NSMakePoint(p.x - strSize.width/2, p.y - strSize.height/2)
								   withRadius:cellWidth/2];
				/*
				[[NSColor redColor] set];
				PSmoveto(p.x,p.y);
				PSlineto(p.x+5,p.y+5);
				PSlineto(p.x+5,p.y);
				PSfill();
				*/
				RELEASE(attrStr);
			}
		}
	}


}

- (NSRect) rectForGoLocation:(GoLocation)loc
{
	if (_go == nil)
	{
		return NSZeroRect;
	}

	NSRect retRect;
	retRect.origin = [self pointForGoLocation:loc];
	retRect.size = NSZeroSize;
	retRect = NSInsetRect(retRect,-cellWidth/2, -cellWidth/2);
	return retRect;
}

- (NSPoint) pointForGoLocation:(GoLocation)loc
{
	NSPoint retpnt;

	if (_go == nil)
	{
		return NSZeroPoint;
	}

	retpnt.x = (loc.column - 1) * cellWidth + NSMinX(boardRect) + cellWidth/2;
	retpnt.y = (loc.row - 1) * cellWidth + NSMinY(boardRect) + cellWidth/2;

	return retpnt;
}

- (GoLocation) goLocationForPoint:(NSPoint)p
{
	GoLocation retloc;

	if (_go == nil)
	{
		return GoNoLocation;
	}

	retloc.column = (p.x - NSMinX(boardRect))/cellWidth + 1;
	retloc.row = (p.y - NSMinY(boardRect))/cellWidth + 1;

	if (retloc.column < 0 || retloc.row < 0 ||
			retloc.column > boardSize || retloc.row > boardSize)
	{
		retloc = GoNoLocation;
	}

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
