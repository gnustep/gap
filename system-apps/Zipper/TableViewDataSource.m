#import <AppKit/AppKit.h>
#import "TableViewDataSource.h"
#import "Archive.h"
#import "FileInfo.h"

#define X_INVALID_COL_ID	@"InvalidColumIdentiferException"

@implementation TableViewDataSource : NSObject

- (void)setArchive:(Archive *)archive;
{
	ASSIGN(_archive, archive);
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
	NSSize size;
	FileInfo *fileInfo = [_archive elementAtIndex: row];
	NSString *identifier = [tableColumn identifier];

	if ([identifier isEqual:COL_ID_NAME])
	{
		image = [[NSWorkspace sharedWorkspace] iconForFile: [fileInfo filename]];

		size = [image size];
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

//------------------------------------------------------------------------------
// NSTableView delegate methods
//------------------------------------------------------------------------------
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	NSString *identifier = [tableColumn identifier];
	NSImage *image;

	if ([identifier isEqual:COL_ID_NAME])
	{
		[_archive sortByFilename];
	}
	else if ([identifier isEqual:COL_ID_DATE])
	{
		[_archive sortByDate];
	}
	else if ([identifier isEqual:COL_ID_SIZE])
	{
		[_archive sortBySize];
	}
	else if ([identifier isEqual:COL_ID_PATH])
	{
		[_archive sortByPath];
	}
	else if ([identifier isEqual:COL_ID_RATIO])
	{
		[_archive sortByRatio];
	}
	else
	{
		[NSException raise:X_INVALID_COL_ID format:@"invalid column identifier '%@'", identifier];
	}
	
	// reflect the current sort ordering in tableColumn's indicator image
	image = nil;
	if ([_archive sortOrder] == NSOrderedAscending)
	{
		// TODO gnustep-gui does not have an image  preregistered under that name
		image = [NSImage imageNamed:@"NSAscendingSortIndicator"];
	}
	else
	{
		// TODO gnustep-gui does not have an image  preregistered under that name
		image = [NSImage imageNamed:@"NSDescendingSortIndicator"];
	}
	// TODO this isn't implemented in gnustep-gui
	[tableView setIndicatorImage:image inTableColumn:tableColumn];

	[tableView reloadData];
	// deselect the colum that was clicked (probably a workaround for Renaissance behaviour)
	[tableView deselectColumn:[tableView selectedColumn]];
}

@end
