/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GoDocumentInspector.h"

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

- (void) awakeFromNib
{
	[self setDocument:nil];
	[self setUIEnabled:NO];
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

		Player *player = [_document playerForColorType:BlackPlayerType];
		[blackPlayerButton setImage:[[player info] objectForKey:@"Image"]];
		NSLog(@"info %@",[player info]);
		player = [_document playerForColorType:WhitePlayerType];
		[whitePlayerButton setImage:[[player info] objectForKey:@"Image"]];

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
		[blackPlayerButton setImage:nil];
		[whitePlayerButton setImage:nil];
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
  /* insert your code here */
}


- (void) apply: (id)sender
{
	[_document setBoardSize:[[boardSizeChooser selectedItem] tag]];
}

- (void) revert: (id)sender
{
	NSLog(@"revert");
}

@end
