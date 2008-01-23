/*
 Project: Vespucci
 VEDocument.m

 Copyright (C) 2007-2008

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

#import "VEDocument.h"

static NSString *homePage = @"";

@implementation VEDocument

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
}

- (id)initWithContentsOfFile:(NSString *)fileName ofType:(NSString *)docType
{
    VEDocument *doc;
    
    doc = [[VEDocument alloc] init];
    NSAssert(doc != NULL, @"VEDocument - document can't be nil");
    
    return doc;
}


- (NSData *)dataRepresentationOfType:(NSString *)type {
    // Implement to provide a persistent data representation of your document OR remove this and implement the file-wrapper or file path based save methods.
    return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
    // Implement to load a persistent data representation of your document OR remove this and implement the file-wrapper or file path based load methods.
    return YES;
}

- (void)makeWindowControllers
{
    windowController = [[VEWinController alloc] initWithWindowNibName:@"VEDocument"];
    [self addWindowController:windowController];
    [windowController release];

    /* set undo levels */
    [[self undoManager] setLevelsOfUndo:1];
}

- (WebView *)webView
{
    return [windowController webView];
}

- (NSString *)homePage
{
    return homePage;
}

- (void)setHomePage:(NSString *)page
{
    if (page != nil)
        homePage = page;
    else
        homePage = @"";
}

- (void)loadUrl:(NSURL *)anUrl
{
    NSLog(@"VEDocument - set url to %@", anUrl);
    NSAssert([self webView] != nil, @"loadUrl: webView can't be nil");
    if (anUrl != nil)
        [[[self webView] mainFrame] loadRequest:[NSURLRequest requestWithURL:anUrl]];
}

@end
