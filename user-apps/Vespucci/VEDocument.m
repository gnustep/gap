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

#import "VEDocument.h"

static NSString *homePage = @"";

@implementation VEDocument

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    NSUserDefaults *defaults;
    NSString *hp;

    [super windowControllerDidLoadNib:aController];
    defaults = [NSUserDefaults standardUserDefaults];
    hp = [defaults stringForKey:@"Homepage"];
    [self setHomePage:hp];
}

- (id)initWithContentsOfFile:(NSString *)fileName ofType:(NSString *)docType
{
    VEDocument *doc;
    NSString *urlStr;
    
    NSLog(@"filename: %@", fileName);
    urlStr = [@"file://" stringByAppendingString:fileName];
    NSLog(@"url: %@", urlStr);
    doc = [[VEDocument alloc] init];
    [doc  loadUrl:[NSURL URLWithString:[NSURL URLWithString:urlStr]]];
    
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
    /* instantiate PRWindowController */
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
    NSLog(@"Document - set url to %@", anUrl);
    if (anUrl != nil)
        [[[self webView] mainFrame] loadRequest:[NSURLRequest requestWithURL:anUrl]];
}

@end
