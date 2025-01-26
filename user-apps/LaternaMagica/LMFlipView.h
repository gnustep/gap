/* 
   Project: LaternaMagica
   LMFlipView.h

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
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
*/


#import <AppKit/AppKit.h>

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= 1058)
@protocol NSWindowDelegate
@end
#endif

@class AppController;

@interface LMFlipView : NSImageView <NSWindowDelegate>
{
    IBOutlet AppController *controller;
}

- (void)setController:(AppController *)aController;

@end
