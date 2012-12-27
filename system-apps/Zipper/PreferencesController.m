/*

  PreferencesController.m
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
#define TAG_ZIP		7
#define TAG_GZIP	8
#define TAG_GUNZIP	9
#define TAG_BZIP2	10
#define TAG_BUNZIP2	11
#define TAG_UNARJ	12
#define TAG_UNACE	13
#define TAG_ZOO		14
#define TAG_XZ		15

@implementation PreferencesController : NSObject

- (id)init
{
  NSString *string;
  BOOL tarFlag;

  [super init];
  [NSBundle loadNibNamed: @"Preferences" owner: self];
    
  // tar
  string = [Preferences tarExecutable];
  if (!string)
    string = @"";
  [_tarTextField setStringValue:string];

  // unzip
  string = [Preferences unzipExecutable];
  if (!string)
    string = @"";
  [_unzipTextField setStringValue:string];

  // zip
  string = [Preferences zipExecutable];
  if (!string)
    string = @"";
  [_zipTextField setStringValue:string];

  // rar
  string = [Preferences rarExecutable];
  if (!string)
    string = @"";
  [_rarTextField setStringValue:string];

  // lha
  string = [Preferences lhaExecutable];
  if (!string)
    string = @"";
  [_lhaTextField setStringValue:string];

  // lzx
  string = [Preferences lzxExecutable];
  if (!string)
    string = @"";
  [_lzxTextField setStringValue:string];

  // 7z
  string = [Preferences sevenZipExecutable];
  if (!string)
    string = @"";
  [_sevenZipTextField setStringValue:string];

  // gzip 
  string = [Preferences gzipExecutable];
  if (!string)
    string = @"";
  [_gzipTextField setStringValue:string];

  // gunzip 
  string = [Preferences gunzipExecutable];
  if (!string)
    string = @"";
  [_gunzipTextField setStringValue:string];

  // bzip2 
  string = [Preferences bzip2Executable];
  if (!string)
    string = @"";
  [_bzip2TextField setStringValue:string];

  // bunzip2 
  string = [Preferences bunzip2Executable];
  if (!string)
    string = @"";
  [_bunzip2TextField setStringValue:string];

  // unarj 
  string = [Preferences unarjExecutable];
  if (!string)
    string = @"";
  [_unarjTextField setStringValue:string];

  // unace 
  string = [Preferences unaceExecutable];
  if (!string)
    string = @"";
  [_unaceTextField setStringValue:string];

  // zoo 
  string = [Preferences zooExecutable];
  if (!string)
    string = @"";
  [_zooTextField setStringValue:string];

  // xz 
  string = [Preferences xzExecutable];
  if (!string)
    string = @"";
  [_xzTextField setStringValue:string];

  // bsd tar checkbox
  tarFlag = [Preferences isBsdTar];
  [_bsdTarButton setState:tarFlag];

  // default open app text field
  string = [[Preferences defaultOpenApp] lastPathComponent];
  if (!string)
    string = @"";
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

-(void)windowWillClose:(NSNotification *)aNotification
{
  [NSApp stopModal];
}

- (IBAction)okPressed:(id)sender
{
	NSString *string;

	NS_DURING
		string = [_tarTextField stringValue];
		[Preferences setTarExecutable:string];

		string = [_unzipTextField stringValue];
		[Preferences setUnzipExecutable:string];

		string = [_zipTextField stringValue];
		[Preferences setZipExecutable:string];
		
		string = [_rarTextField stringValue];
		[Preferences setRarExecutable:string];
		
		string = [_lhaTextField stringValue];
		[Preferences setLhaExecutable:string];

		string = [_lzxTextField stringValue];
		[Preferences setLzxExecutable:string];

		string = [_sevenZipTextField stringValue];
		[Preferences setSevenZipExecutable:string];

		string = [_gzipTextField stringValue];
		[Preferences setGzipExecutable:string];

		string = [_gunzipTextField stringValue];
		[Preferences setGunzipExecutable:string];

		string = [_bzip2TextField stringValue];
		[Preferences setBzip2Executable:string];

		string = [_bunzip2TextField stringValue];
		[Preferences setBunzip2Executable:string];

		string = [_unarjTextField stringValue];
		[Preferences setUnarjExecutable:string];

		string = [_unaceTextField stringValue];
		[Preferences setUnaceExecutable:string];

		string = [_zooTextField stringValue];
		[Preferences setZooExecutable:string];

		string = [_xzTextField stringValue];
		[Preferences setXzExecutable:string];

		[Preferences setIsBsdTar:[_bsdTarButton state]];
		[Preferences save];

		[_panel performClose:self];
	NS_HANDLER
		NSRunAlertPanel(@"Error in Preferences", [localException reason], nil, nil, nil);
	NS_ENDHANDLER
}

- (IBAction)cancelPressed:(id)sender
{
  [_panel performClose:self];
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
					[Preferences setUnzipExecutable:path];
					break;

				case TAG_ZIP:
					[_zipTextField setStringValue:path];
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
				
				case TAG_GZIP:
					[_gzipTextField setStringValue:path];
					[Preferences setGzipExecutable:path];
					break;
				
				case TAG_GUNZIP:
					[_gunzipTextField setStringValue:path];
					[Preferences setGunzipExecutable:path];
					break;
				
				case TAG_BZIP2:
					[_bzip2TextField setStringValue:path];
					[Preferences setBzip2Executable:path];
					break;
				
				case TAG_BUNZIP2:
					[_bunzip2TextField setStringValue:path];
					[Preferences setBunzip2Executable:path];
					break;
				
				case TAG_UNARJ:
					[_unarjTextField setStringValue:path];
					[Preferences setUnarjExecutable:path];
					break;
				
				case TAG_UNACE:
					[_unaceTextField setStringValue:path];
					[Preferences setUnaceExecutable:path];
					break;
				
				case TAG_ZOO:
					[_zooTextField setStringValue:path];
					[Preferences setZooExecutable:path];
					break;
				
				case TAG_XZ:
					[_xzTextField setStringValue:path];
					[Preferences setXzExecutable:path];
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
