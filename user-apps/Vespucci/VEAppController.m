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

- (void)addBookmarksFromDictionary:(NSDictionary *)dict toMenu:(NSMenu *)menu
{
    int i;
    NSArray *children;

    children = [dict objectForKey:@"Children"];
    
    for (i = 0; i < [children count]; i++)
    {
        NSDictionary *bmDict;
        NSString *bmType;
        NSString *bmTitle;
        
        bmDict = [children objectAtIndex:i];
        bmType = [bmDict objectForKey:@"WebBookmarkType"];
        if ([bmType isEqualToString:@"WebBookmarkTypeList"])
        {
            NSMenuItem *subMenuItem;
            NSMenu *subMenu;
            
            bmTitle = [bmDict objectForKey:@"Title"];
            
            subMenu = [[NSMenu alloc] init];

            subMenuItem = [[NSMenuItem alloc] init];
            [subMenuItem setTitle:bmTitle];
            
            [subMenuItem setSubmenu:subMenu];
            [menu addItem:subMenuItem];
            [self addBookmarksFromDictionary:bmDict toMenu:subMenu];
        } else if ([bmType isEqualToString:@"WebBookmarkTypeLeaf"])
        {
            NSDictionary *uriDict;
            NSString   *bmUrl;
            VEMenuItem *mi;

            uriDict = [bmDict objectForKey:@"URIDictionary"];
            bmTitle = [uriDict objectForKey:@"title"];
            bmUrl = [bmDict objectForKey:@"URLString"];

            mi = [[VEMenuItem alloc] initWithTitle:@"title" action:@selector(loadBookmark:) keyEquivalent:@""];
            [mi setUrl:bmUrl];
            [mi setUrlTitle:bmTitle];
            
            [menu addItem:mi];            
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSMutableDictionary *bookmarks;
    NSString *bookmarksFile;

    [NSApp setServicesProvider:self];
    
    bookmarksFile = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    bookmarksFile = [bookmarksFile stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
    bookmarksFile = [bookmarksFile stringByAppendingPathComponent:@"Bookmarks.plist"];

    NSLog(@"%@", bookmarksFile);

    
    bookmarks = [NSMutableDictionary dictionaryWithContentsOfFile:bookmarksFile];
    [self addBookmarksFromDictionary:bookmarks toMenu:[bookmarksMenu submenu]];
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

/* Add Bookmark Panel handling */

/** called to show the add bookmark panel */
- (IBAction) addBookmark:(id)sender
{
    NSString *title;
    NSString *url;
    
    url = [[[VEDocumentController sharedDocumentController] currentDocument] loadedUrl];
    title = [[[VEDocumentController sharedDocumentController] currentDocument] loadedPageTitle];
 
    [addBkUrlField setStringValue:url];    
    [addBkTitleField setStringValue:title];    

    [addBookmarkPanel makeKeyAndOrderFront:self];
}

/** Add action of the Bookmark Add Panel */
- (IBAction) addBkPanelAdd:(id)sender
{
    NSString *title;
    NSString *url;
    VEMenuItem *mi;
    
    url = [addBkUrlField stringValue];
    title = [addBkTitleField stringValue];
    NSLog(@"Url %@", url);
    NSLog(@"Title %@", title );

    mi = [[VEMenuItem alloc] initWithTitle:@"title" action:@selector(loadBookmark:) keyEquivalent:@""];
    [mi setUrl:url];
    [mi setUrlTitle:title];
    
    [[bookmarksMenu submenu] addItem:mi];
    [addBookmarkPanel performClose:self];
}

- (IBAction) addBkPanelCancel:(id)sender
{
    [addBookmarkPanel performClose:self];
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
