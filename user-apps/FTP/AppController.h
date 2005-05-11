/* 
   Project: FTP

   Copyright (C) 2005 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2005-03-30
   
   Application Controller

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/
 

#import <AppKit/AppKit.h>
#import "ftpclient.h"
#import "localclient.h"
#import "fileTable.h"

@interface AppController : NSObject
{
    IBOutlet NSTableView         *localView;
    IBOutlet NSTableView         *remoteView;
    IBOutlet NSPopUpButton       *localPath;
    IBOutlet NSPopUpButton       *remotePath;
    IBOutlet NSTextField         *infoMessage;
    IBOutlet NSTextField         *infoProgress;
    IBOutlet NSProgressIndicator *progBar;
    
    IBOutlet NSWindow     *logWin;
    IBOutlet NSTextView   *logTextField;
    
    IBOutlet NSPanel      *connectPanel;
    IBOutlet NSTextField  *connAddress;
    IBOutlet NSTextField  *connPort;
    IBOutlet NSTextField  *connUser;
    IBOutlet NSTextField  *connPass;
    IBOutlet NSButton     *connAnon;
    
    fileTable *localTableData;
    fileTable *remoteTableData;
    ftpclient *ftp;
    localclient *local;
}

+ (void)initialize;

- (id)init;
- (void)dealloc;

- (void)awakeFromNib;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotif;
- (BOOL)applicationShouldTerminate:(id)sender;
- (void)applicationWillTerminate:(NSNotification *)aNotif;
- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName;

- (void)updatePath :(NSPopUpButton *)path :(NSArray *)pathArray;

- (IBAction)changePathFromMenu:(id)sender;
- (void)listDoubleClick:(id)sender;
- (IBAction)downloadButton:(id)sender;
- (IBAction)uploadButton:(id)sender;

- (IBAction)disconnect:(id)sender;

- (IBAction)showPrefPanel:(id)sender;
- (IBAction)showFtpLog:(id)sender;
- (void)appendTextToLog:(NSString *)textChunk;

- (IBAction)showConnPanel:(id)sender;
- (IBAction)connectConn:(id)sender;
- (IBAction)cancelConn:(id)sender;
- (IBAction)anonymousConn:(id)sender;

@end

