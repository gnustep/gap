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

@interface ArchiveService (PrivateAPI)
- (void)createTarArchiveForFiles:(NSArray *)filenames archiveType: (NSString *) archiveType;
@end

@implementation ArchiveService : NSObject

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
	    if ([archiveType isEqual: @"TarGZ"])
	      {
		 NSString *archiveFile = [panel filename];
		 // create the archive
		 [TarArchive createArchive:archiveFile withFiles:filenames archiveType:@"TarGZ"];
	      }
	    else if ([archiveType isEqual: @"TarBZ2"])
	      {
		 NSString *archiveFile = [panel filename];
		 // create the archive
		 [TarArchive createArchive:archiveFile withFiles:filenames archiveType:@"TarBZ2"];
	      }
	  }
}

@end
