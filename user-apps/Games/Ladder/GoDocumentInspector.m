/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GoDocumentInspector.h"

@implementation GoDocumentInspector

- (id) init
{
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(setDocument:)
			   name:GoDocumentDidBecomeMainNotification
			 object:nil];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(unsetDocument:)
			   name:GoDocumentDidBecomeMainNotification
			 object:nil];

	return self;
}

- (void) setDocument:(NSNotification *) not
{
	ASSIGN(_document, [not object]);
	int boardSize = [_document boardSize];
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
}

- (void) unsetDocument:(NSNotification *) not
{
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
