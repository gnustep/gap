/*
	Controller.m - Controller class for Jishyo.app
	Copyright (C) 2005, Rob Burns
	May 30, 2005

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02111, USA.
*/

#ifdef __APPLE__
#include "GNUstep.h"
#endif

#include "Controller.h"
#include "Dictionary.h"

#define EXACT_SEARCH	23
#define SIMILAR_SEARCH	32
#define RELATED_SEARCH	55

@interface Controller (Private)

- (void) _localizeGNUstepMenu;
- (void) _localizeMacOSMenu;
- (BOOL) _validateResult: (NSString *)result;
- (NSString *) _formatResult: (NSString *)result;

@end

@implementation Controller

+ (void) initialize
{
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
		[NSNumber numberWithInt: EXACT_SEARCH], @"SearchType", nil];

   [defaults registerDefaults:appDefaults];
}

- (void) dealloc
{
	RELEASE(_dict);

	[super dealloc];
}

- (id) init
{
	if ((self = [super init]))
	{
		_dict = [[Dictionary alloc] init];
		[_dict setCallback: @selector(handleSearchResult:) target: self];
		_searchType = EXACT_SEARCH;	
	
		return self;
	}
	return nil;
}

- (void) awakeFromNib
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	int index;

	[theWindow setTitle: _(@"Jishyo")];
	[theWindow setFrameUsingName: @"MainWindow"];		
	
	[searchButton setImage: [NSImage imageNamed: @"Search"]];
	[resultView setFont: [NSFont systemFontOfSize: 16]];

	[[typePopup itemAtIndex: 0] setTitle: _(@"Exact Search")];
	[[typePopup itemAtIndex: 0] setTag: EXACT_SEARCH];	
	[[typePopup itemAtIndex: 1] setTitle: _(@"Similar Search")];
	[[typePopup itemAtIndex: 1] setTag: SIMILAR_SEARCH];	
	[[typePopup itemAtIndex: 2] setTitle: _(@"Related Search")];
	[[typePopup itemAtIndex: 2] setTag: RELATED_SEARCH];	

	index = [typePopup indexOfItemWithTag: [[def objectForKey: @"SearchType"] intValue]];
	[typePopup selectItemAtIndex: index];
	_searchType = [[typePopup selectedItem] tag];

	[typePopup setRefusesFirstResponder: YES];
	[searchButton setRefusesFirstResponder: YES];
	
#ifndef __APPLE__
	[self _localizeGNUstepMenu];
#else
	[self _localizeMacOSMenu];
#endif
}

- (void) search: (id)sender
{
	// don't search for 0 or 1 character 'words'
	if ([[searchField stringValue] length] > 1)
	{
		[resultView setString: @""];
		_currentSearch = [searchField stringValue];
		[_dict searchForWord: [searchField stringValue]];
		[searchField becomeFirstResponder];
	}
}

- (void) searchTypeChanged: (id)sender
{
	_searchType = [[typePopup selectedItem] tag];
}

// FIXME handleSearchResult can probably be made more efficient
// by using NSTextStorage

- (id) handleSearchResult: (id)result
{
	NSString *temp = nil;

	if ([self _validateResult: result])
	{
		temp = [self _formatResult: result];
		[resultView setString: [[resultView string] stringByAppendingString: result]];
		[resultView scrollRangeToVisible:NSMakeRange([[resultView string] length], 0)];
		[resultView display];
	}
	return nil;
}

- (BOOL) windowShouldClose: (id)sender
{
	[NSApp terminate:self];	
    return YES;
}

- (void) applicationWillTerminate: (NSNotification *)aNotification
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

	[theWindow saveFrameUsingName: @"MainWindow"];		

	[def setObject: [NSNumber numberWithInt: [[typePopup selectedItem] tag]]
	        forKey:	@"SearchType"];
	[def synchronize];
}

@end

@implementation Controller (Private)

- (void) _localizeGNUstepMenu
{
	NSMenu *men;

	[[NSApp mainMenu] setTitle: _(@"Jishyo")];

	// localize the Edit menu

	men = [[[NSApp mainMenu] itemWithTitle: @"Edit"] submenu];
	[men setTitle: _(@"Edit")];

	[[men itemWithTitle: @"Cut"] setTitle: _(@"Cut")];
	[[men itemWithTitle: @"Copy"] setTitle: _(@"Copy")];
	[[men itemWithTitle: @"Paste"] setTitle: _(@"Paste")];
	[[men itemWithTitle: @"Select All"] setTitle: _(@"Select All")];

	// localize the Windows menu

	men = [[[NSApp mainMenu] itemWithTitle: @"Windows"] submenu];
	[men setTitle: _(@"Windows")];

	[[men itemWithTitle: @"Arrange In Front"] setTitle: _(@"Arrange In Front")];
	[[men itemWithTitle: @"Miniaturize Window"] setTitle: _(@"Miniaturize Window")];
	[[men itemWithTitle: @"Close Window"] setTitle: _(@"Close Window")];

	// localize the Services menu

	men = [[[NSApp mainMenu] itemWithTitle: @"Services"] submenu];
	[men setTitle: _(@"Services")];

	// localize the main menu

	men = [NSApp mainMenu];

	[[men itemWithTitle: @"Info Panel..."] setTitle: _(@"Info Panel...")];
	[[men itemWithTitle: @"Edit"] setTitle: _(@"Edit")];
	[[men itemWithTitle: @"Windows"] setTitle: _(@"Windows")];
	[[men itemWithTitle: @"Services"] setTitle: _(@"Services")];
	[[men itemWithTitle: @"Hide"] setTitle: _(@"Hide")];
	[[men itemWithTitle: @"Quit"] setTitle: _(@"Quit")];
}

- (void)_localizeMacOSMenu
{

}

// The search results that the xjdic code returns are
// exhaustive. So, we have a few ways to narrow the result
// set to a quantity more managable.

- (BOOL) _validateResult: (NSString *)result
{
	NSArray *elements;
	NSMutableArray *words = [NSMutableArray arrayWithCapacity: 1];
	NSEnumerator *eEnum = nil;
	NSMutableString *cur;
	NSMutableString *verbSearch;
	int rLength, sLength;
	NSRange range;

	rLength = sLength = 0;
	
	elements = [result componentsSeparatedByString: @"/"];
	eEnum = [elements objectEnumerator];

	// 'Exact Search' works by removing the initial grammar information from
	// the first entry, and comparing against whats left. It also
	// adds "to " to a copy of the search string and compares against it.
	// this will catch verbs.

	if (_searchType == EXACT_SEARCH)
	{
		cur = [NSMutableString stringWithString: [elements objectAtIndex: 1]];
		range = [cur rangeOfString: @")"];
		
		if ([cur rangeOfString: @"("].location == 0 && 
		range.location != NSNotFound && [cur length] > range.location+1)
		{
			[cur deleteCharactersInRange: NSMakeRange(0,range.location+2)];
		}

		verbSearch = [NSMutableString stringWithString: @"to "];
		[verbSearch appendString: _currentSearch]; 
		
		if ([cur isEqualToString: _currentSearch] || 
		[cur isEqualToString: verbSearch])
		{
			return YES;
		}
		return NO;
	}

	// 'Similar Search' works by only accepting results where the end of the first entry
	// matches the search term. This allows for adjectives (green -> light green), 
	// as well as other things. maybe too much, its still pretty permissive

	if (_searchType == SIMILAR_SEARCH)
	{
		sLength = [_currentSearch length];
		rLength = [(NSString *)[elements objectAtIndex: 1] length];

		if (rLength < sLength)
		{
			return NO;
		}
		
		cur = [elements objectAtIndex: 1];
		if([[cur substringFromIndex: rLength - sLength] isEqualToString: _currentSearch])
		{
			return YES;
		}
		return NO;
	}

	// 'Related Search' works by getting rid of partial word matches. example:
	// frogman != frog. Even weeding out partial word matches, you 
	// are left with 70 or 80 (or more) results for many queries.
	
	if (_searchType == RELATED_SEARCH)
	{
		while ((cur = [eEnum nextObject]))
		{
			[words addObjectsFromArray: [cur componentsSeparatedByString: @" "]];
		}
		return [words containsObject: _currentSearch];
	}

	//In the seemingly impossible case that we end up here return YES
	NSLog(@"Catastrophe! Search type is not set!");
	return YES;
}

// FIXME _formatResult is unimplemented

- (NSString *) _formatResult: (NSString *)result
{
	// NSArray *parts = [result componentsSeparatedByString: @"/"];

	// handle the first part specially. it is the japanese word in kanji,
	// with pronunciation key

	// NSString *temp = [parts objectAtIndex: 0];

	return result;
}

@end


