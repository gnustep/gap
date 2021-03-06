/*
 Project: Vespucci
 VEWinController.h

 Copyright (C) 2007-2008

 Author: Ing. Riccardo Mottola, Dr. H. Nikolaus Schaller

 Created: 2007-03-13

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
#import <WebKit/WebPreferences.h>
#import <WebKit/WebKit.h>



@interface VEWinController : NSWindowController
{
   IBOutlet NSTextField *urlField;	// web address field
   IBOutlet WebView *webView;		// the Web view
   IBOutlet NSTextField *status;	// the status

   IBOutlet NSButton<NSValidatedUserInterfaceItem> *backButton;
   IBOutlet NSButton<NSValidatedUserInterfaceItem> *forwardButton;
   
   WebPreferences *webPrefs;
}

- (WebView *)webView;

- (IBAction) setUrl:(id)sender;
- (IBAction) goBackHistory:(id)sender;
- (IBAction) goForwardHistory:(id)sender;
- (NSString *)loadedUrl;
- (NSString *)loadedPageTitle;

@end
