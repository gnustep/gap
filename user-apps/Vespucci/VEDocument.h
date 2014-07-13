/*
 Project: Vespucci
 VEDocument.h

 Copyright (C) 2007-2014

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

#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import "VEWinController.h"

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_2)
@class NSError;
#endif


@interface VEDocument : NSDocument
{
  VEWinController *windowController;
  NSPrintInfo        *printInfo;
  
#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_3)
  @protected NSURL *_docURL;
#endif
}

- (WebView *)webView;
- (NSString *)homePage;
- (void)setHomePage:(NSString *)page;
- (void)loadUrl:(NSURL*)anUrl;
- (NSString *)loadedUrl;
- (NSString *)loadedPageTitle;

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_3)
- (void)setFileURL:(NSURL *)absoluteURL;
- (NSURL *)fileURL;
- (id)initWithContentsOfURL:(NSURL *)aURL ofType:(NSString *)docType error:(NSError **)outError;
#endif


@end
