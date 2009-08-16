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


@implementation VEAppController

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

- (NSMutableDictionary *)bookmarksFromMenu:(NSMenu *)menu
{
    int i;
    NSMutableArray *children;
    NSMutableDictionary *dict;
    
    children = [NSMutableArray arrayWithCapacity:[menu numberOfItems]];
    dict = [NSMutableDictionary dictionaryWithCapacity:4];

    [dict setObject:children forKey:@"Children"];
    [dict setObject:[menu title] forKey:@"Title"];
    [dict setObject:@"WebBookmarkTypeList" forKey:@"WebBookmarkType"];
    [dict setObject:@"" forKey:@"WebBookmarkUUID"];

    for (i = 0; i < [menu numberOfItems]; i++)
    {
        NSMenuItem *mi;
        
        mi = (NSMenuItem *)[menu itemAtIndex:i];
        if ([mi isKindOfClass:[VEMenuItem class]])
        {
            VEMenuItem *vi;
            NSString *title;
            NSString *url;
            NSMutableDictionary *leafDict;
            NSMutableDictionary *uriDict;
            
            vi = (VEMenuItem *)mi;
            leafDict = [NSMutableDictionary dictionaryWithCapacity:3];
            uriDict = [NSMutableDictionary dictionaryWithCapacity:2];
            
            [leafDict setObject:uriDict forKey:@"URIDictionary"];
            [leafDict setObject:[vi url] forKey:@"URLString"];
            [leafDict setObject:@"WebBookmarkTypeLeaf" forKey:@"WebBookmarkType"];
            [leafDict setObject:@"leaf-uuid" forKey:@"WebBookmarkUUID"];
            
            [uriDict setObject:[vi url] forKey:@""];
            [uriDict setObject:[vi title] forKey:@"title"];
            
            title = [vi title];
            url = [vi url];
            [children addObject:leafDict];
        } else if ([mi hasSubmenu] == YES)
        {
            [children addObject:[self bookmarksFromMenu:[mi submenu]]];
        }
    }
    return dict;
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
            [subMenu setTitle:bmTitle];
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

    [NSApp setServicesProvider:self];
    
    bookmarksFile = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    bookmarksFile = [bookmarksFile stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
    bookmarksFile = [bookmarksFile stringByAppendingPathComponent:@"Bookmarks.plist"];
    [bookmarksFile retain];
    
    bookmarks = [NSMutableDictionary dictionaryWithContentsOfFile:bookmarksFile];
    [self addBookmarksFromDictionary:bookmarks toMenu:[bookmarksMenu submenu]];
}

- (IBAction)showPreferences:(id)sender
{
    WebPreferences *webPrefs;
    NSFont *font;
    NSString *fontName;
    
    webPrefs = [[WebPreferences alloc] initWithIdentifier:@"Vespucci"];
    [javaScriptCheck setState:[webPrefs isJavaScriptEnabled] ? NSOnState : NSOffState];

    fontName = [webPrefs serifFontFamily];
    font = [NSFont fontWithName: fontName size:12.0];
    [self updateFontPreview:fontSerifField :font];
    serifFont = font;
    
    fontName = [webPrefs sansSerifFontFamily];
    font = [NSFont fontWithName: fontName size:12.0];
    [self updateFontPreview:fontSansSerifField :font];
    sansSerifFont = font;
    
    fontName = [webPrefs fixedFontFamily];
    font = [NSFont fontWithName: fontName size:12.0];
    [self updateFontPreview:fontMonoField :font];
    monospacedFont = font;

    [prefPanel makeKeyAndOrderFront:self];
    [webPrefs release];
}

- (IBAction) savePrefs:(id)sender
{
    NSUserDefaults *defaults;
    NSString *homePage;

    WebPreferences *webPrefs;

    defaults = [NSUserDefaults standardUserDefaults];
    webPrefs = [[WebPreferences alloc] initWithIdentifier:@"Vespucci"];

    homePage = [homePageField stringValue];
    NSLog(@"should save homepage: %@", homePage);
    if (homePage != nil)
      [defaults setObject: homePage forKey:@"Homepage"];
    
    [webPrefs setJavaScriptEnabled: [javaScriptCheck state] == NSOnState];

    [webPrefs setSerifFontFamily:[serifFont fontName]];
    [webPrefs setSansSerifFontFamily:[sansSerifFont fontName]];
    [webPrefs setFixedFontFamily:[monospacedFont fontName]];

    [prefPanel performClose:self];
    [defaults synchronize];
    [webPrefs release];
}

- (IBAction) cancelPrefs:(id)sender
{
    [prefPanel performClose:self];
}

- (IBAction) chooseFont:(id)sender
{
  NSFontManager *fontMgr;
  NSTextField *fontField;

  fontMgr = [NSFontManager sharedFontManager];

  if (sender == chooseSerifFontButton)
    fontField = fontSerifField;
  else if (sender == chooseSansFontButton)
    fontField = fontSansSerifField;
  else if (sender == chooseMonoFontButton)
    fontField = fontMonoField;
  else
    NSLog(@"Unexpected sender in choose Font.");
 
  currentFontField = fontField;

  [fontMgr setSelectedFont: [fontField font]  isMultiple:NO];
  [fontMgr setDelegate:self];
  [prefPanel endEditingFor:nil]; /* Mac needs this */
  [fontMgr orderFrontFontPanel: self];
}

- (void) changeFont:(id)sender
{
  NSTextField *fontField;
  NSFont *newFont;
  NSLog(@"change font!");

  fontField = currentFontField;
  newFont = [sender convertFont: [fontField font]];


  if (newFont != nil)
    {
      if (fontField == fontSerifField)
        serifFont = newFont;
      else if (fontField == fontSansSerifField)
        sansSerifFont = newFont;
      else if (fontField == fontMonoField)
        monospacedFont = newFont;

      [self updateFontPreview:fontField :newFont];
    }
}

- (void) updateFontPreview:(NSTextField *)previewField :(NSFont *)font
{
  NSString *fontName;
  NSLog(@"Update FontPreview!");

  fontName = [font fontName];
  if (fontName)
    {
      [previewField setFont:[NSFont fontWithName: fontName size:12.0]];
      [previewField setStringValue: fontName];
    }
  else
    {
      [previewField setFont:[NSFont systemFontOfSize: -1]];
      [previewField setStringValue: @"(unset)"];
    }

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
    NSWindow *topWindow;

    types = [pboard types];

    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType]))
    {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain a string.",
                                   @"Pasteboard couldn't give string.");
        return;
    }

    NSLog(@"Received string from service: %@", pboardString);

    /* check if there is a current document open which is empty and reuse it
        else create a new document */
    /* we use orderedWindows because orderedDocuments is not implemented in GNUstep */
    dc = [VEDocumentController sharedDocumentController];
    doc = nil;
    topWindow = nil;
    topWindow = [[[NSApplication sharedApplication] orderedWindows] objectAtIndex:0];
    if (topWindow != nil)
        doc = [dc documentForWindow:topWindow];
    NSLog(@"[openURL] current loaded url in document: %@", [doc loadedUrl]);
    
    if (doc != nil)
    {
        if (([doc loadedUrl] != nil) && [[doc loadedUrl] length] > 0)
            doc = [super openUntitledDocumentOfType:@"HTML Document" display:YES];
    } else {
        doc = [super openUntitledDocumentOfType:@"HTML Document" display:YES];
        NSAssert(doc != nil, @"openDocWithURL: document can't be nil here");
    }

    urlStr = canonicizeUrl(pboardString);
    [doc  loadUrl:[NSURL URLWithString:urlStr]];

    return;
}

/** delegate called on NSApplication termination */
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSMutableDictionary *bkDict;
    NSString *pathStr;
    NSFileManager *fileMgr;
    
    fileMgr = [NSFileManager defaultManager];
    bkDict = [self bookmarksFromMenu: [bookmarksMenu submenu]];
    [bkDict removeObjectForKey:@"Title"];
    [bkDict setObject:@"Root" forKey:@"WebBookmarkUUID"];
    [bkDict setObject:@"1" forKey:@"WebBookmarkFileVersion"];

    pathStr = [bookmarksFile stringByDeletingLastPathComponent];
    if (![fileMgr fileExistsAtPath:pathStr])
      {
	[fileMgr createDirectoryAtPath:pathStr attributes:nil];
      }
    if ([bkDict writeToFile:bookmarksFile atomically:NO] == NO)
    {
        NSRunAlertPanel(@"Attention", @"Could not save Bookmarks", @"Ok", nil, nil);
    }
}

- (void)dealloc
{
    [bookmarksFile release];
    [super dealloc];
}


@end
