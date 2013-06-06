/* -*- mode: objc -*-

 Project: FTP

 Copyright (C) 2013 Free Software Foundation

 Author: Riccardo Mottola

 Created: 2013-06-05

 Controller class to get an new name from the user in a panel dialog.

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "GetNameController.h"

@implementation GetNameController : NSObject


-(NSInteger)runAsModal
{
  NSInteger result;
  
  if (!panel)
    {
      if (![NSBundle loadNibNamed: @"GetName" owner: self])
        {
          return NSAlertAlternateReturn;
        }
    }
  
  [panel makeKeyAndOrderFront: nil];
  [panel makeFirstResponder: textField];
  
  result = [NSApp runModalForWindow: panel];

  return result;
}

-(void)setTitle:(NSString *)title
{
  [panel setTitle:title];
}

-(void)setDescription:(NSString *)desc
{
  [description setStringValue:desc];
}

-(void)setName:(NSString  *)name
{
  NSLog(@"setting name to: %@", name);
  [textField setStringValue:name];
}

-(NSString *)name;
{
  NSLog(@"returning; %@", [textField stringValue]);
  return [textField stringValue];
}

-(IBAction)okPressed:(id)sender
{
  [panel close];
  [NSApp stopModalWithCode: NSAlertDefaultReturn];
}

-(IBAction)cancelPressed:(id)sender
{
  [panel close];
  [NSApp stopModalWithCode: NSAlertAlternateReturn];
}

@end 
