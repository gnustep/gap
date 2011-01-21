/* 
   Project: LaternaMagica
   LMFlipView.m

   Copyright (C) 2006-2011 Riccardo Mottola

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
#define KC_LEFTARROW 113
#define KC_RIGHTARROW 114
#define KC_UPARROW 111
#define KC_DOWNARROW 116
#define KC_DELETE 119
#define KC_BACKSPACE 22
#else
#define KC_ESCAPE 53
#define KC_LEFTARROW 123
#define KC_RIGHTARROW 124
#define KC_UPARROW 126
#define KC_DOWNARROW 125
#define KC_DELETE 117
#define KC_BACKSPACE 51
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
  unsigned int modifierFlags;

#ifdef __APPLE__
/* Apple is definitively broken here and on all versions tested it returns for the arrow key
    also a KeyUp event, which it should not, as the Event is specified to be keyDown */
    if ([theEvent type] == NSKeyUp)
        return [super performKeyEquivalent:theEvent];
#endif

    keyCode = [theEvent keyCode];
    modifierFlags = [theEvent modifierFlags];
    if (keyCode == KC_ESCAPE)
      {
        NSLog(@"(keyCode) Escape!");
        [controller setFullScreen:theEvent];
        return YES;
      }
    else if (keyCode == KC_LEFTARROW || keyCode == KC_UPARROW)
      {
        [controller prevImage:theEvent];
        return YES;
      }
    else if (keyCode == KC_RIGHTARROW || keyCode == KC_DOWNARROW)
      {
        [controller nextImage:theEvent];
        return YES;
      }
    else if (keyCode == KC_BACKSPACE || keyCode == KC_DELETE)
      {
	if (modifierFlags & NSShiftKeyMask)
	  [controller removeImage:theEvent];
	else
	  [controller eraseImage:theEvent];
        return YES;
      }
    else
      NSLog(@"keyCode %d", keyCode);    
    return [super performKeyEquivalent:theEvent];
}

@end
