/* 
   Project: LaternaMagica
   LMFlipView.m

   Copyright (C) 2006-2007 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2006-06-11

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

#import "LMFlipView.h"


@implementation LMFlipView

- (BOOL)isFlipped
{
    return YES;
}

/* ---- Key event methods ---- */

/** respond to key equivalents which are not bound do menu items */
-(BOOL)performKeyEquivalent: (NSEvent*)theEvent
{
    NSString *chars;
    
    chars = [theEvent characters];
    if ([chars length] == 1)
    {
        unichar c;
        NSLog(@"characters: %@", chars);
        c = [chars characterAtIndex: 0];
        
        if (c == NSDeleteCharFunctionKey)
        {
            NSLog(@"Delete!");
            return YES;
        } else if (c == NSBackspaceCharacter)
        {
            NSLog(@"Backspace!");
            return YES;
        } else {
            NSLog(@"theEvent %@", theEvent);
        }
    }
    
    unsigned short keyCode;
    keyCode = [theEvent keyCode];
    
    if (keyCode == 53)
    {
        NSLog(@"Escape!");
        return YES;
    } else if (keyCode == 51)
    {
        NSLog(@"Backspace!");
        return YES;
    }
    
    return [super performKeyEquivalent:theEvent];
}

@end
