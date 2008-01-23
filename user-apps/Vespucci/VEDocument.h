/*
 Project: Vespucci
 VEDocument.h

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

#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import "VEWinController.h"


@interface VEDocument : NSDocument {
    VEWinController *windowController;
}

- (WebView *)webView;
- (NSString *)homePage;
- (void)setHomePage:(NSString *)page;
- (void)loadUrl:(NSURL*)anUrl;


@end
