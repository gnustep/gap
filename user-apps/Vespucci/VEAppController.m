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

- (BOOL) applicationOpenUntitledFile: (id)sender
{
    VEDocument *doc;

    doc = [[NSDocumentController sharedDocumentController] 
    openUntitledDocumentOfType: @"HTML" display: YES];

    return (doc != nil);
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

}

- (IBAction)showPreferences:(id)sender
{
    [prefPanel makeKeyAndOrderFront:self];
}

- (IBAction) savePrefs:(id)sender
{
    NSUserDefaults *defaults;
    NSString *homePage;

    defaults = [NSUserDefaults standardUserDefaults];

    homePage = [homePageField stringValue];
    NSLog(@"should save homepage: %@", homePage);
    [defaults setObject: homePage forKey:@"Homepage"];

    [prefPanel performClose:self];
    [defaults synchronize];
}

- (IBAction) cancelPrefs:(id)sender
{
    [prefPanel performClose:self];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
    if ([aNotification object] == prefPanel)
    {
        NSUserDefaults *defaults;
        NSString *hp;

        defaults = [NSUserDefaults standardUserDefaults];
        hp = [defaults stringForKey:@"Homepage"];
        NSLog(@"in windowDidBecomeKey homepage is %@", hp);
        [homePageField setStringValue:hp];
    }
}

@end
