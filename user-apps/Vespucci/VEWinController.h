/*
 Project: Vespucci

 Copyright (C) 2007

 Author: Ing. Riccardo Mottola, Dr. H. Nikolaus Schaller

 Created: 2007-03-13

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>

@interface VEWinController : NSObject
{
   IBOutlet NSTextField *urlField;	// web addresssearch field
   IBOutlet WebView *webView;		// the Web view
   IBOutlet NSTextField *status;	// the status
}

- (IBAction) setUrl:(id)sender;

@end
