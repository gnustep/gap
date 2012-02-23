/*

  PrefController.m
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
#import "PreferencesController.h"
#import "Preferences.h"
#import "Archive.h"

#define TAG_TAR		1
#define TAG_UNZIP	2
#define TAG_RAR		3
#define TAG_LHA		4
#define TAG_LZX		5
#define TAG_SEVEN_ZIP	6

@implementation PreferencesController : NSObject

- (id)init
{
  NSString *string;
  BOOL tarFlag;

  [super init];
  [NSBundle loadNibNamed: @"Preferences" owner: self];
    
  // tar
  string = [Preferences tarExecutable];
  [_tarTextField setStringValue:string];
  // zip
  string = [Preferences zipExecutable];
  [_unzipTextField setStringValue:string];
  // rar
  string = [Preferences rarExecutable];
  [_rarTextField setStringValue:string];
  // lha
  string = [Preferences lhaExecutable];
  [_lhaTextField setStringValue:string];
  // lzx
  string = [Preferences lzxExecutable];
  [_lzxTextField setStringValue:string];
  // 7z
  string = [Preferences sevenZipExecutable];
  [_sevenZipTextField setStringValue:string];
  // bsd tar checkbox
  tarFlag = [Preferences isBsdTar];
  [_bsdTarButton setState:tarFlag];
  // default open app text field
  string = [[Preferences defaultOpenApp] lastPathComponent];
  [_defaultOpenApp setStringValue:string];

    return self;
}

- (void)dealloc
{
        [_panel release];
        [_archiveClass release];
        [super dealloc];
}

/**
 * runs the Preferences Panel in a modal event loop
 */
- (void)showPreferencesPanel
{
  [NSApp runModalForWindow:_panel];
  // control flow returns to the panel ... until 'ok' or 'cancel' is pressed

  [_panel close];
}

- (IBAction)okPressed:(id)sender
{
	NSString *string;

	NS_DURING
		string = [_tarTextField stringValue];
		[Preferences setTarExecutable:string];

		string = [_unzipTextField stringValue];
		[Preferences setZipExecutable:string];
		
		string = [_rarTextField stringValue];
		[Preferences setRarExecutable:string];
		
		string = [_lhaTextField stringValue];
		[Preferences setLhaExecutable:string];

		string = [_lzxTextField stringValue];
		[Preferences setLzxExecutable:string];

		string = [_sevenZipTextField stringValue];
		[Preferences setSevenZipExecutable:string];

		[Preferences setIsBsdTar:[_bsdTarButton state]];
		[Preferences save];

		[NSApp stopModal];
	NS_HANDLER
		NSRunAlertPanel(@"Error in Preferences", [localException reason], nil, nil, nil);
	NS_ENDHANDLER
}

- (IBAction)cancelPressed:(id)sender
{
  [NSApp stopModal];
}

- (IBAction)findExecutable:(id)sender
{
	NSOpenPanel *openPanel;
	int rc;
				
	openPanel = [NSOpenPanel openPanel];
	[openPanel setTitle:@"Find executable"];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];

	rc = [openPanel runModalForDirectory:@"/" file:nil types:nil];
	if (rc == NSOKButton)
	{
		NSString *path = [openPanel filename];
		
		NS_DURING
			switch ([sender tag])
			{
				case TAG_TAR:
					[_tarTextField setStringValue:path];
					[Preferences setTarExecutable:path];
					break;
					
				case TAG_UNZIP:
					[_unzipTextField setStringValue:path];
					[Preferences setZipExecutable:path];
					break;
				
				case TAG_RAR:
					[_rarTextField setStringValue:path];
					[Preferences setRarExecutable:path];
					break;
					
				case TAG_LHA:
					[_lhaTextField setStringValue:path];
					[Preferences setLhaExecutable:path];
					break;

				case TAG_LZX:
					[_lzxTextField setStringValue:path];
					[Preferences setLzxExecutable:path];
					break;

				case TAG_SEVEN_ZIP:
					[_sevenZipTextField setStringValue:path];
					[Preferences setSevenZipExecutable:path];
					break;
				
				default:
					[NSException raise:NSInvalidArgumentException 
						format:@"invalid tag of find button"];
			}
		NS_HANDLER
			NSRunAlertPanel(@"Error in Preferences", [localException reason], nil, nil, nil);
		NS_ENDHANDLER
	}
}

- (IBAction)findDefaultOpenApp:(id)sender
{
	NSOpenPanel *openPanel;
	NSString *gnustepSystemApps;
	int rc;
				
	gnustepSystemApps = [NSSearchPathForDirectoriesInDomains(NSApplicationDirectory,
				NSSystemDomainMask, YES) objectAtIndex:0];
	
	openPanel = [NSOpenPanel openPanel];
	[openPanel setTitle:@"Find default open app"];
	[openPanel setTreatsFilePackagesAsDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	
	rc = [openPanel runModalForDirectory:gnustepSystemApps file:nil types:nil];
	if (rc == NSOKButton)
	{
		[_defaultOpenApp setStringValue:[[openPanel filename] lastPathComponent]];
		[Preferences setDefaultOpenApp:[openPanel filename]];
	}	
}

@end
