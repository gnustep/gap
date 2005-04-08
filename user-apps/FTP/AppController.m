/* 
   Project: FTP

   Copyright (C) 2005 Free Software Foundation

   Author: 

   Created: 2005-03-30 09:43:03 +0200 by multix
   
   Application Controller

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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "AppController.h"

@implementation AppController

+ (void)initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
  if ((self = [super init]))
    {
    }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)awakeFromNib
{
//  [[NSApp mainMenu] setTitle:@"FTP"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotif
{
    /* startup code */
}

- (BOOL)applicationShouldTerminate:(id)sender
{
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotif
{
}

- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName
{
    return NO;
}

- (IBAction)showPrefPanel:(id)sender
{
}

- (IBAction)showFtpLog:(id)sender
{
    [logWin makeKeyAndOrderFront:self];
}

// This routine is called after adding new results to the text view's backing store.
// We now need to scroll the NSScrollView in which the NSTextView sits to the part
// that we just added at the end
- (void)scrollToVisible:(id)ignore {
    [logTextField scrollRangeToVisible:NSMakeRange([[logTextField string] length], 0)];
}

- (IBAction)appendTextToLog:(NSString *)textChunk
{
    /* add the textChunk to the NSTextView's backing store as an attributed string */
    [[logTextField textStorage] appendAttributedString: [[[NSAttributedString alloc]
                             initWithString: textChunk] autorelease]];

    /* setup a selector to be called the next time through the event loop to scroll
       the view to the just pasted text.  We don't want to scroll right now,
       because of a bug in Mac OS X version 10.1 that causes scrolling in the context
       of a text storage update to starve the app of events */
    [self performSelector:@selector(scrollToVisible:) withObject:nil afterDelay:0.0];

}

/* --- connection panel methods --- */
- (IBAction)showConnPanel:(id)sender
{
    [connectPanel makeKeyAndOrderFront:self];
}

- (IBAction)connectConn:(id)sender
{
    char tempStr[1024];
    char tempStr2[1024];
    
    [connectPanel performClose:nil];
    ftp = [[ftpclient alloc] initWithController:self];
    NSLog(@"Finished launching");
    [[connAddress stringValue] getCString:tempStr];
    [ftp connect:[connPort intValue] :tempStr];
    [[connUser stringValue] getCString:tempStr];
    [[connPass stringValue] getCString:tempStr2];
    [ftp authenticate:tempStr :tempStr2];
    NSLog(@"before dirlist");
    [ftp getDirList:"/"];
    NSLog(@"after dirlist");
    [ftp disconnect];
}

- (IBAction)cancelConn:(id)sender
{
    [connectPanel performClose:nil];
}

- (IBAction)anonymousConn:(id)sender
{
}

@end
