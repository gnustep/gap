/*
    ShellController.m

    This program is part of the GNUstep Application Project

    Copyright (C) 2002 Gregory John Casamento

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Gregory John Casamento <greg_casamento@yahoo.com>
    14218 Oxford Drive, Laurel, MD 20707, USA
*/

/* ShellController.m created by heron on Sat 02-Dec-2000 */

#import "ShellController.h"
#import "TerminalDelegate.h"
#import <Foundation/NSRange.h>

@implementation ShellController
- init
{
    NSPipe
    	*input = [NSPipe pipe],
    	*output = [NSPipe pipe];
    NSString *defaultShell = @"/usr/gnu/bin/bash";
    
    [super init];

    _shellTask = [[NSTask alloc] init];
    [_shellTask setLaunchPath: defaultShell];
    [_shellTask setStandardInput: input];
    [_shellTask setStandardOutput: output];
    [_shellTask launch];

    if([_shellTask isRunning])
      {
        NSLog(@"shell started");
      }
    else
      {
        return nil;
      }
    return self;
}

- (void) awakeFromNib
{
    if([_shellTask isRunning])
      {
        [shellWindow setTitle: [_shellTask launchPath]];
      }

    [textView setDelegate: self];
    //[textView setSelectable: NO];
    //[textView setEditable: NO];
    [shellWindow setContentView: scrollView];
    [shellWindow makeKeyAndOrderFront: self];
    NSLog(@"Awake");
}

// Delegate methods for the text view.
- (void)textDidBeginEditing:(NSNotification *)aNotification
{
    NSLog(@"Text did begin editing");
}

- (void)textDidChange:(NSNotification *)aNotification
{
    id textObject = [aNotification object];
    int length = [[textObject string] length];
    char inputch = ([[textObject string] cString])[length-1];
    NSFileHandle *output = [[_shellTask standardOutput] fileHandleForReading];
    NSData *outData = [output availableData];
    NSString *outString = [NSString stringWithCString: (char *)[outData bytes]];
    NSString *string = nil;
    
    //NSLog(@"Text did change");
    //NSLog(@"%@", [textObject string]);
    //[textObject setString: [[textObject string] stringByAppendingString: @"test"]];
    string = [[textObject string] stringByAppendingString: outString];
    
    NSLog(@"%@",[string substringWithRange: NSMakeRange(length-1,1)]);

    
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    NSLog(@"Text did end editing");
}

- (BOOL)textShouldBeginEditing:(NSText *)aTextObject
{
    NSLog(@"Text should begin editing");
    return YES;
}

- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
    NSLog(@"Text should end editing");
    return NO;
}

// Delegate methods for the window.

@end
