/* All Rights reserved */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include "GoDocumentInspector.h"
#include "AppController.h"
#include "PlayerController.h"

@implementation GoDocumentInspector

- (id) init
{
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(setDocumentNotified:)
			   name:GoDocumentDidBecomeMainNotification
			 object:nil];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(unsetDocumentNotified:)
			   name:GoDocumentDidResignMainNotification
			 object:nil];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(turnBegin:)
			   name:GameTurnDidBeginNotification
			 object:nil];

	return self;
}

- (void) setUIEnabled:(BOOL)enable
{
	[boardSizeChooser setEnabled:enable];
	[showHistoryButton setEnabled:enable];
	[blackPlayerButton setEnabled:enable];
	[whitePlayerButton setEnabled:enable];

	[handicapStepper setEnabled:enable];
	[komiStepper setEnabled:enable];
	[revertButton setEnabled:enable];
	[applyButton setEnabled:enable];

	[handicapText setEditable:enable];
	[komiText setEditable:enable];
	if (enable)
	{
		[handicapText takeIntValueFrom:handicapStepper];
		[komiText takeFloatValueFrom:komiStepper];
	}
	else
	{
		[handicapText setStringValue:@""];
		[komiText setStringValue:@""];
		[turnText setStringValue:@""];
	}


	if (!enable || _document == nil)
	{
		return;
	}

	/* FIXME Temporary */
	NSArray *parray = [[[NSApp delegate] playerController] allPlayerClasses];
	NSArray *items;

	items = [blackPlayerButton itemArray];

	[[items objectAtIndex:0] setTitle:[[parray objectAtIndex:0] description]];
	[[items objectAtIndex:0] setImage:[[[parray objectAtIndex:0] info] objectForKey:@"Image"]];

	[[items objectAtIndex:1] setTitle:[[parray objectAtIndex:1] description]];
	[[items objectAtIndex:1] setImage:[[[parray objectAtIndex:1] info] objectForKey:@"Image"]];
	if ([[_document playerForColorType:BlackPlayerType] isMemberOfClass:[parray objectAtIndex:0]])
	{
		[blackPlayerButton selectItemAtIndex:0];
	}
	else
	{
		[blackPlayerButton selectItemAtIndex:1];
	}


	items = [whitePlayerButton itemArray];

	[[items objectAtIndex:0] setTitle:[[parray objectAtIndex:0] description]];
	[[items objectAtIndex:0] setImage:[[[parray objectAtIndex:0] info] objectForKey:@"Image"]];

	[[items objectAtIndex:1] setTitle:[[parray objectAtIndex:1] description]];
	[[items objectAtIndex:1] setImage:[[[parray objectAtIndex:1] info] objectForKey:@"Image"]];
	if ([[_document playerForColorType:WhitePlayerType] isMemberOfClass:[parray objectAtIndex:0]])
	{
		[whitePlayerButton selectItemAtIndex:0];
	}
	else
	{
		[whitePlayerButton selectItemAtIndex:1];
	}
}

- (void) setDocument:(GoDocument *)godoc
{
	ASSIGN(_document, godoc);
	int boardSize;
	if (_document != nil)
	{
		boardSize = [_document boardSize];
		[self setUIEnabled:YES];

		NSArray *items = [boardSizeChooser itemArray];
		NSEnumerator *en = [items objectEnumerator];
		id item;

		while ((item = [en nextObject]))
		{
			if ([item tag] == boardSize)
			{
				[boardSizeChooser selectItem:item];
				break;
			}
		}

		/*
		Player *player = [_document playerForColorType:BlackPlayerType];
		[blackPlayerButton setImage:[[player info] objectForKey:@"Image"]];
		NSLog(@"info %@",[player info]);
		player = [_document playerForColorType:WhitePlayerType];
		[whitePlayerButton setImage:[[player info] objectForKey:@"Image"]];
		*/

		if ([_document turn] == BlackPlayerType)
		{
			[turnText setStringValue:@"Black Player's Turn"];
		}
		else if ([_document turn] == WhitePlayerType)
		{
			[turnText setStringValue:@"White Player's Turn"];
		}
		else
		{
			[turnText setStringValue:@""];
		}

	}
	else
	{
		[self setUIEnabled:NO];
		boardSize = 0;
		/*
		[blackPlayerButton setImage:nil];
		[whitePlayerButton setImage:nil];
		*/
	}
}

- (void) turnBegin:(NSNotification *)notification
{
	if ([notification object] != [_document go])
	{
		return;
	}

	if ([_document turn] == BlackPlayerType)
	{
		[turnText setStringValue:@"Black Player's Turn"];
	}
	else if ([_document turn] == WhitePlayerType)
	{
		[turnText setStringValue:@"White Player's Turn"];
	}
	else
	{
		[turnText setStringValue:@""];
	}
}

- (void) setDocumentNotified:(NSNotification *) not
{
	[self setDocument:[not object]];
}

- (void) unsetDocumentNotified:(NSNotification *) not
{
	if ([not object] == _document)
	{
		[self setDocument:nil];
	}
}


- (void) setShowHistory: (id)sender
{
	[_document setShowHistory:[sender intValue]];
}


- (void) setPlayer: (id)sender
{
	NSLog(@"set player");
	/*
	[[NSApp delegate] orderFrontPlayerPanel:sender];
	id playerController = [[NSApp delegate] playerController];
	*/

	NSArray *parray = [[[NSApp delegate] playerController] allPlayerClasses];
	int i;

	i = [sender indexOfSelectedItem];

	[_document setPlayer:[[parray objectAtIndex:i] player]
			forColorType:sender == blackPlayerButton?BlackPlayerType:WhitePlayerType];

}


- (void) apply: (id)sender
{
	[_document setBoardSize:[[boardSizeChooser selectedItem] tag]];


	/* FIXME Temporary */
	NSArray *parray = [[[NSApp delegate] playerController] allPlayerClasses];
	int i;

	i = [blackPlayerButton indexOfSelectedItem];

	[_document setPlayer:[[parray objectAtIndex:i] player]
			forColorType:BlackPlayerType];

	i = [whitePlayerButton indexOfSelectedItem];

	[_document setPlayer:[[parray objectAtIndex:i] player]
			forColorType:WhitePlayerType];
}

- (void) revert: (id)sender
{
	NSLog(@"revert");
}

- (void) awakeFromNib
{
	[self setDocument:nil];
	[self setUIEnabled:NO];
}

@end
