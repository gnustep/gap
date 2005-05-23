#include "PlayerController.h"
#include <AppKit/AppKit.h>

@class PlayerCell;

static NSMutableArray *__playerClasses;

@implementation PlayerController

+ (void) initialize
{
	if (__playerClasses == nil)
	{
		__playerClasses = [NSMutableArray new];
	}
}

- (id) init
{
	return self;
}

- (void) awakeFromNib
{
	[playerBrowser setCellClass:[PlayerCell class]];
	[playerBrowser setMaxVisibleColumns:2];
}

- (void) dealloc
{
	[super dealloc];
}

- (NSArray *) allPlayerClasses
{
	return __playerClasses;
}

- (void) addPlayerClass:(Class)newPlayerClass;
{
	if (![__playerClasses containsObject:newPlayerClass])
	{
		[__playerClasses addObject:newPlayerClass];
	}
}

- (void) browser: (NSBrowser *)sender
 willDisplayCell: (NSBrowserCell *)cell
		   atRow: (int)row
		  column: (int)column
{
	id player;
	NSDictionary *dict;
	id value;

	if (column == 0)
	{
		player = [__playerClasses objectAtIndex:row];
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
		player = [__playerClasses objectAtIndex:[sender selectedRowInColumn:0]];
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
		return [__playerClasses count];
	}
	else
	{
		id player = [__playerClasses objectAtIndex:[sender selectedRowInColumn:0]];
		NSString *path = [NSString pathWithComponents:[[[sender path] pathComponents] subarrayWithRange:NSMakeRange(0, column)]];
		NSDictionary *dict = [player dictionaryForPath:path];
		NSArray *leaves = [dict objectForKey:@"LeavesArray"];
		return [leaves count];
	}
}

@end
