/* 
   Project: RemoteDesk

   Copyright (C) 2006 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2006-09-11
   
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
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA..
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
    [[NSApp mainMenu] setTitle:@"RemoteDesk"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotif
{
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

- (void)showPrefPanel:(id)sender
{
}

- (IBAction)setDisplaySize:(id)sender
{
    int item;
    item = [dispPresets indexOfSelectedItem];
    switch(item)
    {
        case 0:
            [dispW setStringValue:@"1280"];
            [dispH setStringValue:@"1024"];
            break;
        case 1:
            [dispW setStringValue:@"1024"];
            [dispH setStringValue:@"768"];
            break;
        case 2:
            [dispW setStringValue:@"800"];
            [dispH setStringValue:@"600"];
            break;
        default:
            break;
    }
}


- (IBAction)connect:(id)sender
{
    NSTask *task;
    NSMutableArray *arguments;
    NSString *launchPath = @"rdesktop";
    NSString *remote;
    NSString *pass;
    NSString *username;
    NSString *dW, *dH;

    remote = [remoteHost stringValue];
    if (remote == nil || [remote length] == 0)
    {
        if (NSRunInformationalAlertPanel(nil, @"Please enter a Remote Host", @"Ok", nil, nil) == NSAlertDefaultReturn)
            ;
        return;
    }
    pass = [password stringValue];
    username = [userName stringValue];

    arguments = [NSMutableArray arrayWithCapacity:3];
    if ([dispBitDepth indexOfSelectedItem] >= 0)
    {
        [arguments addObject:[@"-a" stringByAppendingString:[dispBitDepth stringValue]]];
    }
    
    if (username != nil && [username length] > 0)
    {
        [arguments addObject:[@"-u" stringByAppendingString:username]];
    	if (pass != nil && [pass length] > 0)
            [arguments addObject:[@"-p" stringByAppendingString:pass]];
    }
    dW = [dispW stringValue];
    dH = [dispH stringValue];
    if ((dW != nil && [dW length] > 0) && (dH != nil && [dH length] > 0))
    {
        NSString *s;
        s = [@"-g" stringByAppendingString:dW];
        s = [s stringByAppendingString:@"x"];
        s = [s stringByAppendingString:dH];
        [arguments addObject:s];
    }

    if ([keybLayout indexOfSelectedItem] >= 0)
    {
        [arguments addObject:[@"-k" stringByAppendingString:[keybLayout stringValue]]];
    }

    [arguments addObject:remote];
    task = [NSTask launchedTaskWithLaunchPath:launchPath arguments:[NSArray arrayWithArray:arguments]];
}

@end
