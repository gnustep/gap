/*

  PreferencesController.h
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

#import <Foundation/NSObject.h>

@class NSPanel, NSForm, NSTextField, ScrollView, Archive;

@interface PreferencesController : NSObject
{
  IBOutlet NSPanel *_panel;
  IBOutlet NSScrollView *scrollView;
  IBOutlet NSButton *_bsdTarButton;
  IBOutlet NSTextField *_defaultOpenApp;

  IBOutlet NSTextField *_tarTextField;
  IBOutlet NSTextField *_unzipTextField;
  IBOutlet NSTextField *_zipTextField;
  IBOutlet NSTextField *_rarTextField;
  IBOutlet NSTextField *_lhaTextField;
  IBOutlet NSTextField *_lzxTextField;
  IBOutlet NSTextField *_sevenZipTextField;
  IBOutlet NSTextField *_gzipTextField;
  IBOutlet NSTextField *_gunzipTextField;
  IBOutlet NSTextField *_bzip2TextField;
  IBOutlet NSTextField *_bunzip2TextField;
  IBOutlet NSTextField *_unarjTextField;
  IBOutlet NSTextField *_unaceTextField;
  IBOutlet NSTextField *_zooTextField;
  IBOutlet NSTextField *_xzTextField;
	
	
  // this holds a reference to an Archive subclass that the user
  // needs to set before he can leave the prefs dialog
  id _archiveClass;
}

- (void)showPreferencesPanel;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)okPressed:(id)sender;
- (IBAction)findExecutable:(id)sender;
- (IBAction)findDefaultOpenApp:(id)sender;

@end

