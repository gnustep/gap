/*

  AppDelegate.m
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
#import "AppDelegate.h"
#import "ZipArchive.h"
#import "TarArchive.h"
#import "RarArchive.h"
#import "LhaArchive.h"
#import "LzxArchive.h"
#import "GzipArchive.h"
#import "SevenZipArchive.h"
#import "ZooArchive.h"
#import "PreferencesController.h"
#import "ArchiveService.h"

@implementation AppDelegate : NSObject

/**
 * load all Archive subclasses so that they can register their supported file extensions
 */
+ (void)initialize
{
	[LhaArchive class];
	[RarArchive class];
	[TarArchive class];
	[ZipArchive class];
	[LzxArchive class];
	[GzipArchive class];
	[SevenZipArchive class];
	[ZooArchive class];
}

//------------------------------------------------------------------------------
// NSApp delegate methods
//------------------------------------------------------------------------------

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication
{
  return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)note
{	
	[NSApp setServicesProvider:[[ArchiveService alloc] init]];
}

/**
 * do cleanup, especially remove temporary files that were created while we ran
 */
-(void)applicationWillTerminate:(NSNotification *)aNotification
{
	NSEnumerator *cursor;
	NSString *element;
	
	// clean up all temporary Zipper directories
	cursor = [[[NSFileManager defaultManager] directoryContentsAtPath:NSTemporaryDirectory()]
		objectEnumerator];
	while ((element = [cursor nextObject]) != nil)
	{
		if ([element hasPrefix:@"Zipper"])
		{
			NSString *path;
			
			path = [NSString pathWithComponents:[NSArray arrayWithObjects:NSTemporaryDirectory(),
				element, nil]];
			[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
		}
	}
}

//------------------------------------------------------------------------------
// action methods
//------------------------------------------------------------------------------
- (void)showPreferences:(id)sender
{
  PreferencesController *prefController;

  prefController = [[PreferencesController alloc] init];

  [prefController showPreferencesPanel];

  [prefController release];
}
	
@end
