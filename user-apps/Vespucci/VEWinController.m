/*
 Project: Vespucci

 Copyright (C) 2007

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

#import "VEWinController.h"

@implementation VEWinController

- (void)dealloc
{
    [webView release];
    [super dealloc];
}

- (void) awakeFromNib
{
}

- (void)windowDidLoad
{
    [webView setFrameLoadDelegate:self];
    [webView setUIDelegate:self];
    [webView setMaintainsBackForwardList:YES];
}

- (void) showStatus:(NSString *) str
{
    [status setStringValue:str];
}

// delegate methods
- (WebView *) webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    [self showStatus:@"create web view"];
    return sender;
}

- (void) webViewShow:(WebView *)sender
{
    [self showStatus:@"show web view in new window"];
}

- (void) webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if(frame == [sender mainFrame])
    {
    	[self showStatus:@"Loading..."];
    }
}

- (void) webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
  if(frame == [sender mainFrame])
        [[sender window] setTitle:title];
}

- (void) webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    NSLog(@"webview=%@", sender);
    NSLog(@"webview mainFrame=%@", [sender mainFrame]);
    NSLog(@"frame=%@", frame);
    NSLog(@"frame childFrames=%@", [frame childFrames]);
    NSLog(@"frame dataSource=%@", [frame dataSource]);
    NSLog(@"frame dataSource pageTitle=%@", [[frame dataSource] pageTitle]);
    NSLog(@"frame dataSource textEncodingName=%@", [[frame dataSource] textEncodingName]);
    NSLog(@"frame frameView=%@", [frame frameView]);
    NSLog(@"frame name=%@", [frame name]);
    NSLog(@"frame parentFrame=%@", [frame parentFrame]);
    NSLog(@"frame provisionalDataSource=%@", [frame provisionalDataSource]);
    NSLog(@"frame webView=%@", [frame webView]);
  
    // test: print subviews hierarchy
    if(frame == [sender mainFrame])
    {
      [self showStatus:@"Done."];
    } else
    {
      [self showStatus:@"Subframe Done."];
    }
}

- (IBAction) setUrl:(id)sender
{
   NSString *url;
   
   url = [urlField stringValue];
   NSLog(@"set url to %@", url);
   [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (IBAction) goBackHistory:(id)sender
{
    NSLog(@"go back wc");
    NSLog(@"backlist is long: %d", [[webView backForwardList] backListCount]);
    [webView goBack];
}

- (IBAction) goForwardHistory:(id)sender
{
    NSLog(@"go forward wc");
    NSLog(@"backlist is long: %d", [[webView backForwardList] forwardListCount]);
    [webView goForward];
}

@end
