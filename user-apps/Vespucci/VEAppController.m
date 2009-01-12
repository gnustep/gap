/*
 Project: Vespucci
 VEAppController.m

 Copyright (C) 2007-2009

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
#import "VEDocumentController.h"
#import "VEFunctions.h"
#import "VEMenuItem.h"


@implementation VEAppContoller

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication
{
    return YES;
}

- (BOOL) applicationOpenUntitledFile: (id)sender
{
    VEDocument *doc;

    doc = [[VEDocumentController sharedDocumentController] 
    openUntitledDocumentOfType: @"HTML Document" display: YES];

    return (doc != nil);
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    VEDocumentController *dc;
    VEDocument *doc;

    dc = [VEDocumentController sharedDocumentController];
    doc = [dc openDocumentWithContentsOfFile:filename display:YES];

    return (doc != nil);
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSMutableDictionary *bookmarks;
    VEMenuItem *mi;
    NSArray *b1;

    [NSApp setServicesProvider:self];
    
    bookmarks = [NSMutableDictionary dictionaryWithCapacity:1];
    b1 = [NSArray arrayWithObjects:@"http://gap.nongnu.org", @"GAP Project", nil];
    
    mi = [[VEMenuItem alloc] initWithTitle:@"title" action:@selector(loadBookmark:) keyEquivalent:@""];
    [mi setUrl:[b1 objectAtIndex:0]];
    [mi setUrlTitle:[b1 objectAtIndex:1]];
    
    [[bookmarksMenu submenu] addItem:mi];
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

- (IBAction) loadBookmark:(id)sender
{
    VEMenuItem *senderMenu;
    
    NSLog(@"load bookmark!");
    senderMenu = (VEMenuItem *)sender;
    NSLog(@"url: %@", [senderMenu url]);
    NSLog(@"title: %@", [senderMenu title]);
    
    [[[VEDocumentController sharedDocumentController] currentDocument] loadUrl:[NSURL URLWithString:[senderMenu url]]];
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

/* service provider */
- (void)openURL:(NSPasteboard *)pboard
                 userData:(NSString *)data
                    error:(NSString **)error
{
    NSString *pboardString;
    NSArray *types;
    NSString *urlStr;
    VEDocumentController *dc;
    VEDocument *doc;

    types = [pboard types];

    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType]))
    {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain a string.",
                                   @"Pasteboard couldn't give string.");
        return;
    }

    NSLog(@"Received string from service: %@", pboardString);


    dc = [VEDocumentController sharedDocumentController];
    doc = [dc openUntitledDocumentOfType:@"HTML Document" display:YES];
    urlStr = canonicizeUrl(pboardString);
    [doc  loadUrl:[NSURL URLWithString:urlStr]];


    return;
}

@end
