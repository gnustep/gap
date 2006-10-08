/* 
   Project: RemoteDesk

   Copyright (C) 2006 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2006-09-11
   
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
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
*/

#include <AppKit/AppKit.h>

@interface AppController : NSObject
{
    IBOutlet NSTextField   *remoteHost;
    IBOutlet NSTextField   *userName;
    IBOutlet NSTextField   *password;
    IBOutlet NSTextField   *dispW;
    IBOutlet NSTextField   *dispH;
    IBOutlet NSPopUpButton *dispPresets;
    IBOutlet NSPopUpButton *dispBitDepth;
    IBOutlet NSPopUpButton *keybLayout;
}

+ (void)initialize;

- (id)init;
- (void)dealloc;

- (void)awakeFromNib;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotif;
- (BOOL)applicationShouldTerminate:(id)sender;
- (void)applicationWillTerminate:(NSNotification *)aNotif;
- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName;

- (void)showPrefPanel:(id)sender;

- (IBAction)setDisplaySize:(id)sender;
- (IBAction)connect:(id)sender;

@end
