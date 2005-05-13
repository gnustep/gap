#include "PlayerController.h"
#include <AppKit/AppKit.h>

@class PlayerCell;

@implementation PlayerController
- (void) awakeFromNib
{
	[playerBrowser setCellClass:[PlayerCell class]];
	[playerBrowser setMaxVisibleColumns:2];
}

- (id) init
{
	ASSIGN(_players, [NSMutableArray array]);
	return self;
}

- (void) dealloc
{
	RELEASE(_players);
	[super dealloc];
}

- (NSArray *) allPlayers
{
	return _players;
}

- (void) addPlayer:(Player *)newPlayer
{
	[_players addObject:newPlayer];
}

- (void) browser: (NSBrowser *)sender
 willDisplayCell: (NSBrowserCell *)cell
		   atRow: (int)row
		  column: (int)column
{
	Player *player;
	NSDictionary *dict;
	id value;

	if (column == 0)
	{
		player = [_players objectAtIndex:row];
		dict = [player info];
		if (dict)
		{
			value = [dict objectForKey:@"Image"];
			if (value != nil)
			{
				[cell setImage:value];
			}
			value = [dict objectForKey:@"Name"];
			if (value != nil)
			{
				[cell setTitle:value];
			}
			else
			{
				[cell setTitle:[player description]];
			}
		}
		else
		{
			[cell setTitle:[player description]];
		}
	}
	else
	{
		player = [_players objectAtIndex:[sender selectedRowInColumn:0]];
	}

	dict = [player dictionaryForPath:[sender path]];
	if (dict != nil)
	{
		NSArray *leaves = [dict objectForKey:@"LeavesArray"];
		if (leaves && [leaves count] > 0)
		{
			[cell setLeaf:YES];
		}
		else
		{
			[cell setLeaf:NO];
		}

		[cell setTitle:[dict objectForKey:@"Name"]];
	}
	else
	{
		[cell setLeaf:YES];
	}
}

- (int) browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
	if (column == 0)
	{
		return [_players count];
	}
	else
	{
		Player *player = [_players objectAtIndex:[sender selectedRowInColumn:0]];
		NSString *path = [NSString pathWithComponents:[[[sender path] pathComponents] subarrayWithRange:NSMakeRange(0, column)]];
		NSDictionary *dict = [player dictionaryForPath:path];
		NSArray *leaves = [dict objectForKey:@"LeavesArray"];
		return [leaves count];
	}
}

@end
