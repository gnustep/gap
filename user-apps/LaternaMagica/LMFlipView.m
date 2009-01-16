/* 
   Project: LaternaMagica
   LMFlipView.m

   Copyright (C) 2006-2009 Riccardo Mottola

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
#import "AppController.h"

#ifdef GNUSTEP
#define KC_ESCAPE 9
#else
#define KC_ESCAPE 53
#endif

@implementation LMFlipView

- (BOOL)isFlipped
{
    return YES;
}

/* ---- Key event methods ---- */

/** respond to key equivalents which are not bound do menu items */
-(BOOL)performKeyEquivalent: (NSEvent*)theEvent
{
    unsigned short keyCode;

    keyCode = [theEvent keyCode];
    NSLog(@"keyCode %d", keyCode);
    if (keyCode == KC_ESCAPE)
    {
        NSLog(@"(keyCode) Escape!");
        [controller setFullScreen:theEvent];
        return YES;
    }
    
    return [super performKeyEquivalent:theEvent];
}

@end
