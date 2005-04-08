#include <AppKit/AppKit.h>
#include "AppController.h"
#include "StoneUI.h"

@implementation AppController

- (void) applicationWillFinishLaunching: (NSNotification*)aNotification
{
	id go = AUTORELEASE([Go new]);
	[go setBoardSize:11];
	[go setStoneClass:[StoneUI class]];

	int size = [go boardSize];
	int r,c;

	for (r = 1; r <= size; r++)
	for (c = 1; c <= size; c++)
	{
		[go setStoneWithColor:random()%2
				   atLocation:MakeGoLocation(r,c)];
	}

	/*
	[go setStoneWithColor:WhiteStone
			   atLocation:MakeGoLocation(1,19)];
	[go setStoneWithColor:WhiteStone
			   atLocation:MakeGoLocation(19,19)];
			   */

	[board setGo:go];
	[board setTileImage:AUTORELEASE([[NSImage alloc] initWithContentsOfFile:@"wood.jpg"])];
}

@end

