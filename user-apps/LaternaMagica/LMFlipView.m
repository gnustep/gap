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

/* we define our own constants */
enum
{
  NSEscapeCharacter = 0x001b,
  NSSpaceCharacter = 0x0020
};

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

/** respond to key equivalents which are not bound to menu items */
-(BOOL)performKeyEquivalent: (NSEvent*)theEvent
{
  NSString *keyStr;
  unichar keyCh;
  unsigned int modifierFlags;

#ifdef __APPLE__
/* Apple is definitively broken here and on all versions tested it returns for the arrow key
    also a KeyUp event, which it should not, as the Event is specified to be keyDown */
    if ([theEvent type] == NSKeyUp)
        return [super performKeyEquivalent:theEvent];
#endif

    keyCh = 0x0;
    keyStr = [theEvent characters];
    if ([keyStr length] > 0)
      keyCh = [keyStr characterAtIndex:0];
    modifierFlags = [theEvent modifierFlags];

    if (keyCh == NSEscapeCharacter)
      {
        [controller setFullScreen:theEvent];
        return YES;
      }
    else if (keyCh == NSLeftArrowFunctionKey || keyCh == NSUpArrowFunctionKey)
      {
        [controller prevImage:theEvent];
        return YES;
      }
    else if (keyCh == NSRightArrowFunctionKey || keyCh == NSDownArrowFunctionKey || keyCh == NSSpaceCharacter)
      {
        [controller nextImage:theEvent];
        return YES;
      }
    else if (keyCh == NSDeleteFunctionKey || keyCh == NSDeleteCharacter)
      {
	if (modifierFlags & NSShiftKeyMask)
	  [controller removeImage:theEvent];
	else
	  [controller eraseImage:theEvent];
	return YES;
      }
    else if (keyCh == 0x72)
      {
	// "r" to rotate clockwise
	[controller rotateImage270:nil];
	return YES;
      }
    else if (keyCh == 0x6c)
      {
	// "l" to rotate counterclockwise
	[controller rotateImage90:nil];
	return YES;
      }
    else
      NSLog(@"keyCh %x", keyCh);    
    return [super performKeyEquivalent:theEvent];
}

@end
