/*

  ZipperDocument.m
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ZipperDocument.h"
#import "ZipperCell.h"
#import "Archive.h"
#import "TableViewDataSource.h"
#import "PreferencesController.h"
#import "Preferences.h"
#import "NSFileManager+Custom.h"
#import "FileInfo.h"

#define X_INVALID_COL_ID	@"InvalidColumIdentiferException"

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#define sel_isEqual(s1,s2) ((s1)==(s2))
#endif

@interface ZipperDocument (PrivateAPI)
- (BOOL)openArchiveWithPath:(NSString *)path;
- (void)addRatioColumn;
- (void)removeRatioColumn;
- (void)extractIncludingPathInfo:(BOOL)includePathInfo;
- (void)setArchive:(Archive *)archive;
- (void)openFile:(NSString *)file withDefaultApp:(NSString *)defaultApp;
- (Class)archiveClassForFile:(NSString *)filename;
- (Class)archiveClassByFileExtension:(NSString *)path;
- (Class)archiveClassByFileContents:(NSString *)path;
- (BOOL)createUnarchiveDestinationIfNecessary:(NSString *)path;
@end

@implementation ZipperDocument : NSDocument

- (id)init
{
	[super init];
	_tableViewDataSource = nil;
	return self;
}

- (void)dealloc
{
	[_archive release];
	[_tableViewDataSource release];
	[super dealloc];
}

//-----------------------------------------------------------------------------
// NSDocument overrides
//-----------------------------------------------------------------------------
/*" Name of the .gsmarkup file to load */
- (NSString *)windowNibName
{
	return @"ZipperDocument";
}

/*" Override of NSDocument, called when document is about to be opened */
- (void)windowControllerDidLoadNib:(NSWindowController *)controller;
{
	NSSize size;
	NSTableColumn *tableColumn;
	NSCell *cell = [[ZipperCell alloc] init];

	[super windowControllerDidLoadNib: controller];
	[_tableView setDataSource: [self tableViewDataSource]];
	[_tableView reloadData];
	[_tableView setDoubleAction: @selector(tableViewDoubleAction:)];

	// allow for a little bit more space between the columns
	size = [_tableView intercellSpacing];
	size.width += 5.0;
	[_tableView setIntercellSpacing:size];
		
	// right-align the size column
	tableColumn = [_tableView tableColumnWithIdentifier:COL_ID_SIZE];
	[[tableColumn dataCell] setAlignment:NSRightTextAlignment];
	// set the ZipperCell for the name column
	tableColumn = [_tableView tableColumnWithIdentifier:COL_ID_NAME];
	[tableColumn setDataCell:cell];
	[cell release];	
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
	return [self openArchiveWithPath:fileName];
}

//-----------------------------------------------------------------------------
// Opening archive files
//-----------------------------------------------------------------------------
- (BOOL)openArchiveWithPath:(NSString *)path
{
	Class archiveClass = nil;

	archiveClass = [self archiveClassForFile:path];
	NSAssert1(archiveClass != nil, 
		@"No archive class registered for '%@'. This should not happen", path);	
	if ([archiveClass executableDoesExist] == NO)
	{
		// ouch, no executable set (yet)
		NSString *message;
		PreferencesController *prefsController;
	
		message = [NSString stringWithFormat:
			@"Missing unarchiver for file \"%@\". Please provide a value!", path];
		NSRunAlertPanel(@"Error in Preferences", message, nil, nil, nil);
				
		// bring up the prefs panel
		prefsController = [[PreferencesController alloc] init];
		[prefsController showPreferencesPanel];
		[prefsController release];
		
		// invoke recursively as the unarchiver should have been set in prefs by now
		if ([archiveClass executableDoesExist])
		{
			return [self openArchiveWithPath:path];
		}
		else
		{
			// no archiver executable set via prefs, give up
			return NO;
		} 
	}
	
	if ([archiveClass hasRatio])
	{
		[self addRatioColumn];
	}
	else
	{
		[self removeRatioColumn];
	}
		
	[self setArchive:[archiveClass newWithPath:path]];
	[_archive sortByFilename];
	[_tableView reloadData];

	return YES;
}

- (Class)archiveClassForFile:(NSString *)path
{
	Class archiveClass;
	
	archiveClass = [self archiveClassByFileContents:path];
	if (archiveClass == nil)
	{
		archiveClass = [self archiveClassByFileExtension:path];
	}
	return archiveClass;
}

- (Class)archiveClassByFileExtension:(NSString *)path
{
	NSString *extension, *secondExtension;
	Class archiveClass = nil;

	extension = [[path pathExtension] lowercaseString];
	secondExtension = [[[path stringByDeletingPathExtension] pathExtension] lowercaseString];

	if ([extension isEqual:@""] == NO)
	{
		NSString *fullExtension;
		
		if ([secondExtension isEqual:@""]) 
		{
			// extension is .gz, .bz etc.
			fullExtension = extension;
		}
		else 
		{
			// extension is .tar.gz etc.
			fullExtension = [secondExtension stringByAppendingPathExtension:extension];
		}

		archiveClass = [Archive classForFileExtension:fullExtension];
		if (archiveClass == nil)
		{
			NSLog(@"No archive class registered for '%@'.", fullExtension);
			
			// try only the last extension
			archiveClass = [Archive classForFileExtension:extension];
		}
	}

	return archiveClass;	
}

/*"
 * Peek inside <code>path</code> to determine file type. This is necessary as some file extensions
 * are ambiguous, e.g. .rar files can either be Java resource archives or rar-packaged files 
 */
- (Class)archiveClassByFileContents:(NSString *)path
{
	NSFileHandle *fileHandle;
	NSData *data, *headerData;
	NSEnumerator *archiverEnum;
	Class archiverClass;
	
	fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	data = [fileHandle readDataOfLength:4];
	
	archiverEnum = [[Archive allArchivers] objectEnumerator];
	while ((archiverClass = [archiverEnum nextObject]) != nil)
	{
		headerData = [archiverClass magicBytes];
		if ((headerData != nil) && [headerData isEqualToData:data])
		{
			return archiverClass;
		}
	}
		
	return nil;
}

//-----------------------------------------------------------------------------
// validating the UI
//-----------------------------------------------------------------------------
- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	SEL	action = [anItem action];
	
	if (sel_isEqual(action, @selector(openFile:)) ||	sel_isEqual(action, @selector(showPreferences:))) 
	{
		return YES;
	}
	
	// enable the extract menu item only if we have something to extract
	if (_archive == nil)
	{
		return NO;
	}
	// do not enable the 'extract flat' menu item if the extractor does not support it
	if (([anItem tag] == 2) && ([[_archive class] canExtractWithoutFullPath] == NO))
	{
		return NO;
	}
	return YES;
}

//------------------------------------------------------------------------------
// action methods
//------------------------------------------------------------------------------
- (void)extract:(id)sender
{
	[self extractIncludingPathInfo:YES];
}

- (void)extractFlat:(id)sender
{
	[self extractIncludingPathInfo:NO];
}

- (void)extractIncludingPathInfo:(BOOL)includePathInfo
{
  NSOpenPanel *openPanel;
  int rc;

  if (_archive == nil)
    {
      return;
    }

  openPanel = [NSOpenPanel openPanel];
//[openPanel setDelegate:self];
  [openPanel setTitle:@"Extract to"];
  [openPanel setCanChooseFiles:NO];
  [openPanel setCanChooseDirectories:YES];
	
  rc = [openPanel runModalForDirectory:[Preferences lastExtractDirectory] file:nil types:nil];
  if (rc == NSOKButton)
    {
      NSString *message;
      int result;

      NSString *path = [openPanel directory];

      // make sure the destination path exists
      if ([self createUnarchiveDestinationIfNecessary:path] == NO)
	{
 	  return;
	}

      if ([_tableView selectedRow] == -1)
	{
	  // no rows selected ... extract the whole archive
	  result = [_archive expandFiles:nil withPathInfo:includePathInfo toPath:path];
	}
      else
	{
	  NSNumber *rowIndex;

	  // retrieve selected rows && extract them
	  NSMutableArray *extractFiles = [NSMutableArray array];
	  NSEnumerator *rows = [_tableView selectedRowEnumerator];
	  while ((rowIndex = [rows nextObject]) != nil)
	    {
	      [extractFiles addObject:[_archive elementAtIndex:[rowIndex intValue]]]; 
	    }
	  result = [_archive expandFiles:extractFiles withPathInfo:includePathInfo toPath:path];
	}
		
      // save the selected directory for later
      [Preferences setLastExtractDirectory:path];

      if (!result)
	{
          message = [NSString stringWithFormat:@"Successfully expanded to %@", path];
	}
      else
	{
          message = [NSString stringWithFormat:@"A problem occured expanding archive to %@", path];
	}
      NSRunAlertPanel(@"Expand", message, nil, nil, nil);
    }
}

- (void)selectAll:(id)sender
{
	[_tableView selectAll: self];
}

- (void)deselectAll:(id)sender
{
	[_tableView deselectAll: self];
}

- (void)tableViewDoubleAction:(id)sender
{
	NSEnumerator *enumerator;
	NSMutableArray *filesToExtract;
	NSNumber *row;
	NSString *tempDir;
	FileInfo *info;
	
  	if ([_tableView clickedRow] == -1)
    	{
      		return;
    	}
	// collect all files to extract
	filesToExtract = [NSMutableArray array];
	enumerator = [_tableView selectedRowEnumerator];
	while ((row = [enumerator nextObject]) != nil)
	{
		[filesToExtract addObject:[_archive elementAtIndex:[row intValue]]];
	}
	
	tempDir = [[NSFileManager defaultManager] createTemporaryDirectory];
	[_archive expandFiles:filesToExtract withPathInfo:YES toPath:tempDir];
	// NSWorkspace hopefully knows how to handle the file
	enumerator = [filesToExtract objectEnumerator];
	while ((info = [enumerator nextObject]) != nil)
	{
		NSString *tempFile;
		
		tempFile = [NSString pathWithComponents:[NSArray arrayWithObjects:tempDir, 
			[info fullPath], nil]];
		[self openFile:tempFile withDefaultApp:[Preferences defaultOpenApp]];
	}
}

//- (BOOL)panel:(id)sender isValidFilename:(NSString *)filename
//{
//	NSLog(@"panel:isValidFilename: %@", filename);
//	return YES;
//}
//
//- (NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag
//{
//	NSLog(@"userEnteredFilename: %@", filename);
//	return filename;
//}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (void)addRatioColumn
{
	NSTableColumn *ratioColumn;
	int colIndex;
		
	// do it only if the tableView was already loaded
	if (_tableView != nil)
	{	
		ratioColumn = [_tableView tableColumnWithIdentifier:COL_ID_RATIO];
		if (ratioColumn == nil)
		{
			ratioColumn = [[(NSTableColumn *)[NSTableColumn alloc] initWithIdentifier:COL_ID_RATIO] autorelease];
			[[ratioColumn headerCell] setStringValue:@"Ratio"];
			[ratioColumn setWidth:50.0];
			[[ratioColumn dataCell] setAlignment:NSRightTextAlignment];
			[_tableView addTableColumn:ratioColumn];
		}
		
		// here we have a ratio column for sure
		colIndex = [_tableView columnWithIdentifier:COL_ID_RATIO];
		[_tableView moveColumn:colIndex toColumn:3];

		[_tableView reloadData];
	}
}

- (void)removeRatioColumn;
{	
	if (_tableView != nil)
	{		
		NSTableColumn *ratioCol;

		ratioCol = [_tableView tableColumnWithIdentifier:COL_ID_RATIO];
		if (ratioCol != nil)
		{
			[_tableView removeTableColumn:ratioCol];
		}
	}
}

/**
 * Returns the DataSource for our table view
 */
- (TableViewDataSource *)tableViewDataSource
{
	if (_tableViewDataSource == nil)
	{
		_tableViewDataSource = [[TableViewDataSource alloc] init];
		[_tableViewDataSource setArchive:_archive];
	}
	return _tableViewDataSource;
}

- (void)setArchive:(Archive *)archive
{
  [_archive release];
  _archive = archive;
  [_archive retain];

  // make sure the data source knows the archive as well
  [_tableViewDataSource setArchive:archive];
}

- (void)openFile:(NSString *)file withDefaultApp:(NSString *)defaultApp;
{
	int rc;
	
	// this sux: if the file does not have an extension, NSWorkspace does not know how to 
	// handle it. Handling of files should be based on file's contents instead of its 
	// extension, like the unix command 'file' does.
	rc = [[NSWorkspace sharedWorkspace] openFile:file];
	if (rc == NO) {
		// NSWorkspace could not open the file, try again with the default app we've been given
		if (defaultApp != nil) {
			rc = [[NSWorkspace sharedWorkspace] openFile:file withApplication:defaultApp];
		} else {
			NSRunAlertPanel(@"Could not open", @"No default open application set in preferences", 
				nil, nil, nil);
			return;
		}
	}
			
	if (rc == NO) {
		NSRunAlertPanel(@"Could not open", @"Don't know how to open file %@", nil, nil, nil, file);
	}
}

- (BOOL)createUnarchiveDestinationIfNecessary:(NSString *)path
{
	BOOL isDir, dirExists;
	
	dirExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	
	if (dirExists == NO)
	{
		int rc;
		
		rc = NSRunAlertPanel(@"Nonexisting destination", 
			@"The directory '%@' does not exist, do you want to create it?", @"Yes", @"No", nil,
			path);
		if (rc == NSAlertDefaultReturn)
		{
			[[NSFileManager defaultManager] createDirectoryPathWithParents:path];
		}
		else
		{
			return NO;
		}
	}
		
	return YES;
}

//------------------------------------------------------------------------------
// NSTableView delegate methods
//------------------------------------------------------------------------------
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
  NSString *identifier = [tableColumn identifier];
  NSImage *image;

  if ([identifier isEqual:COL_ID_NAME])
    [_archive sortByFilename];
  else if ([identifier isEqual:COL_ID_DATE])
    [_archive sortByDate];
  else if ([identifier isEqual:COL_ID_SIZE])
    [_archive sortBySize];
  else if ([identifier isEqual:COL_ID_PATH])
    [_archive sortByPath];
  else if ([identifier isEqual:COL_ID_RATIO])
    [_archive sortByRatio];
  else
    [NSException raise:X_INVALID_COL_ID format:@"invalid column identifier '%@'", identifier];
  
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
}

@end
