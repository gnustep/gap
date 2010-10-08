/*
 Project: Vespucci
 VEDocument.m

 Copyright (C) 2007-2010

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


- (id)initWithContentsOfURL:(NSURL *)aURL ofType:(NSString *)docType error:(NSError **)outError
{
  self = [self init];
  if (self != nil)
    {
      NSLog(@"initWithContentsOfURL %@", aURL);
      [self setFileType: docType];
      
      /* at this point the NIB is not loaded yet so the WebView is not valid yet
        we set the URL and filename to load it later once the controller is instantiated */
      [self setFileURL: aURL];
      [self setFileName: [aURL path]];
    }
  
  return self;
}

/* subclassed instead of loadDataRepresentation:ofType: to load local files from the open menu */
- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
  [self setFileType: docType];
  
  /* at this point the NIB is not loaded yet so the WebView is not valid yet
  we set the URL and filename to load it later once the controller is instantiated */
  [self setFileURL: [NSURL fileURLWithPath: fileName]];
  [self setFileName: fileName];
  return YES;
}


- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
  NSLog(@"window did load nib URL: %@", [self fileURL]);
  /* now that the window has loaded we load the previously set URL */
  [self loadUrl: [self fileURL]];
}

- (void)makeWindowControllers
{
    windowController = [[VEWinController alloc] initWithWindowNibName:@"VEDocument"];
    [self addWindowController:windowController];
    [windowController release];    
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
    if (anUrl != nil)
      {
        NSAssert([self webView] != nil, @"loadUrl: webView can't be nil");
        [[[self webView] mainFrame] loadRequest:[NSURLRequest requestWithURL:anUrl]];
      }
}

- (NSString *)loadedUrl
{
    return [windowController loadedUrl];
}

- (NSString *)loadedPageTitle
{
    return [windowController loadedPageTitle];
}


/* implementation of older methods for compatibility */

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_3)
- (void)setFileURL:(NSURL *)absoluteURL
{
  _docURL = absoluteURL;
}
- (NSURL *)fileURL
{
  return _docURL;
}

- (id)initWithContentsOfURL:(NSURL *)aURL ofType:(NSString *)docType
{
  self = [self initWithContentsOfURL: aURL ofType:docType error:nil];  
  return self;
}

#endif

@end
