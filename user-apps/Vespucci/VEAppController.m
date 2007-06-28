/*
 Project: Vespucci

 Copyright (C) 2007

 Author: Ing. Riccardo Mottola

 Created: 2007-06-26

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
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "VEAppController.h"
#import "VEDocument.h"


@implementation VEAppContoller

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication
{
    return YES;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    NSDocumentController *dc;
    VEDocument *doc;

    dc = [NSDocumentController sharedDocumentController];
    doc = [dc openDocumentWithContentsOfFile:filename display:YES];

    return (doc != nil);
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSUserDefaults *defaults;
    NSDictionary   *defDic;


    defaults = [NSUserDefaults standardUserDefaults];

    /* we register default settings */

    /* we read the last recorded value in the user defaults */
}


@end
