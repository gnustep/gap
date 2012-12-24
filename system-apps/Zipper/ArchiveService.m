/*

  ArchiveService.h
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
#import "ArchiveService.h"
#import "TarArchive.h"
#import "ZipArchive.h"
#import "LhaArchive.h"

@interface ArchiveService (PrivateAPI)
- (void)createLhaArchiveForFiles:(NSArray *)filenames archiveType: (NSString *) archiveType;
- (void)createTarArchiveForFiles:(NSArray *)filenames archiveType: (NSString *) archiveType;
- (void)createZipArchiveForFiles:(NSArray *)filenames archiveType: (NSString *) archiveType;
@end

@implementation ArchiveService : NSObject

- (void)createLhaArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createLhaArchiveForFiles:filenames archiveType:nil];
}

- (void)createZipArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createZipArchiveForFiles:filenames archiveType:nil];
}

- (void)createZippedTarArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createTarArchiveForFiles:filenames archiveType:@"TarGZ"];
}
- (void)createBZippedTarArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filenames off the pasteboard!";
		return;
	}
	
	[self createTarArchiveForFiles:filenames archiveType:@"TarBZ2"];
}

- (void)createTarArchiveForFiles:(NSArray *)filenames archiveType: (NSString *) archiveType;
{
	int rc;
	
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setTitle:@"Archive destination"];
	rc = [panel runModalForDirectory:NSHomeDirectory() file:nil];
	if (rc == NSOKButton)
	  {
	    NSString *archiveFile = [panel filename];
	    // create the archive
	    [TarArchive createArchive:archiveFile withFiles:filenames archiveType:archiveType];
	  }
}

- (void)createZipArchiveForFiles:(NSArray *)filenames archiveType: (NSString *) archiveType;
{
	int rc;
	
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setTitle:@"Archive destination"];
	rc = [panel runModalForDirectory:NSHomeDirectory() file:nil];
	if (rc == NSOKButton)
	  {
	     NSString *archiveFile = [panel filename];
	     // create the archive
	     [ZipArchive createArchive:archiveFile withFiles:filenames archiveType:archiveType];
	  }
}

- (void)createLhaArchiveForFiles:(NSArray *)filenames archiveType: (NSString *) archiveType;
{
	int rc;
	
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setTitle:@"Archive destination"];
	rc = [panel runModalForDirectory:NSHomeDirectory() file:nil];
	if (rc == NSOKButton)
	  {
	     NSString *archiveFile = [panel filename];
	     // create the archive
	     [LhaArchive createArchive:archiveFile withFiles:filenames archiveType:archiveType];
	  }
}
@end
