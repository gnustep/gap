/* 
   Project: LaternaMagica
   LMFlipView.m

   Copyright (C) 2006-2010 Riccardo Mottola

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
#define KC_LEFTARROW 100
#define KC_RIGHTARROW 102
#else
#define KC_ESCAPE 53
#define KC_LEFTARROW 123
#define KC_RIGHTARROW 124
#endif

@implementation LMFlipView

- (BOOL)isFlipped
{
    return YES;
}

- (void)setController:(AppController *)aController
{
    controller = aController;
}

/* ---- Key event methods ---- */

/** respond to key equivalents which are not bound do menu items */
-(BOOL)performKeyEquivalent: (NSEvent*)theEvent
{
    unsigned short keyCode;
#ifdef __APPLE__
/* Apple is definitively broken here and on all versions tested it returns for the arrow key
    also a KeyUp event, which it should not, as the Event is specified to be keyDown */
    if ([theEvent type] == NSKeyUp)
        return [super performKeyEquivalent:theEvent];
#endif

    keyCode = [theEvent keyCode];
    if (keyCode == KC_ESCAPE)
      {
        NSLog(@"(keyCode) Escape!");
        [controller setFullScreen:theEvent];
        return YES;
      }
    else if (keyCode == KC_LEFTARROW)
      {
        [controller prevImage:theEvent];
        return YES;
      }
    else if (keyCode == KC_RIGHTARROW)
      {
        [controller nextImage:theEvent];
        return YES;
      }
    NSLog(@"keyCode %d", keyCode);    
    return [super performKeyEquivalent:theEvent];
}

@end
