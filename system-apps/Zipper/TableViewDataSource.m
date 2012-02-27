/*

  TableViewDataSource.m
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <AppKit/AppKit.h>
#import "TableViewDataSource.h"
#import "Archive.h"
#import "FileInfo.h"

#define X_INVALID_COL_ID	@"InvalidColumIdentiferException"

@implementation TableViewDataSource : NSObject

- (void)setArchive:(Archive *)archive;
{
  [_archive release];
  _archive = archive;
  [_archive retain];
}

//------------------------------------------------------------------------------
// Implementation NSTableView DataSource
//------------------------------------------------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_archive elementCount];
}

- (void) tableView: (NSTableView *)tableView willDisplayCell: (id)aCell
   forTableColumn: (NSTableColumn *)tableColumn row: (int)row
{
	NSImage *image;
	FileInfo *fileInfo = [_archive elementAtIndex: row];
	NSString *identifier = [tableColumn identifier];

	if ([identifier isEqual:COL_ID_NAME])
	{
		image = [[NSWorkspace sharedWorkspace] iconForFile: [fileInfo filename]];

		[image setScalesWhenResized: YES];
		[image setSize: NSMakeSize(16,16)];
		[aCell setImage: image];
	}
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
	FileInfo *fileInfo = [_archive elementAtIndex:rowIndex];
	
	NSString *identifier = [aTableColumn identifier];
	if ([identifier isEqual:COL_ID_NAME])
	{
		return [fileInfo filename];
	}
	else if ([identifier isEqual:COL_ID_DATE])
	{
		return [[fileInfo date] descriptionWithCalendarFormat:@"%y-%m-%d %H:%M:%S"];
	}
	else if ([identifier isEqual:COL_ID_SIZE])
	{
		return [fileInfo size];
	}
	else if ([identifier isEqual:COL_ID_PATH])
	{
		return [fileInfo path];
	}
	else if ([identifier isEqual:COL_ID_RATIO])
	{
		return [fileInfo ratio];
	}
	else
	{
		[NSException raise:X_INVALID_COL_ID format:@"invalid column identifier '%@'", identifier];
	}

	// shut up the compiler
	return nil;
}



@end
