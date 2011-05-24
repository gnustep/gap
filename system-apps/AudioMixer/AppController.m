/* 
   Project: AudioMixer
   AppController.m

   Application Controller

   Copyright (C) 2011 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2011-05-23 23:55:14 +0200 by Riccardo Mottola


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

+ (void) initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */
  
  [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id) init
{
  if ((self = [super init]))
    {
    }
  return self;
}

- (void) dealloc
{
  [soundDev release];

  [super dealloc];
}

- (void) awakeFromNib
{
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotif
{
  int level;
  int balance;

  soundDev = [[SoundDevice alloc] init];

  level = [soundDev outMainLevel];
  balance = [soundDev outMainBalance];
  [fieldOutMainLevel setIntValue: level];
  [sliderOutMainLevel setIntValue: level];
  [fieldOutMainBalance setIntValue: balance];
  [sliderOutMainBalance setIntValue: balance];
}

- (BOOL) applicationShouldTerminate: (id)sender
{
  return YES;
}

- (void) applicationWillTerminate: (NSNotification *)aNotif
{
}

- (BOOL) application: (NSApplication *)application
	    openFile: (NSString *)fileName
{
  return NO;
}

- (void) showPrefPanel: (id)sender
{
}

- (IBAction) outMainLevelChanged: (id)sender
{
  int level;

  level = [sliderOutMainLevel intValue];
  [fieldOutMainLevel setIntValue: level];
}

- (IBAction) outMainBalanceChanged: (id)sender
{
  int balance;

  balance = [sliderOutMainBalance intValue];
  [fieldOutMainBalance setIntValue: balance];
}


@end
