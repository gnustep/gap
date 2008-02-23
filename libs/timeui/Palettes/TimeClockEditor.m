/*
 *        .::!!!!::.       *     +               .              *      .
 *     .:!' .:::::. ':                *                    .
 *    :!: ::'      ': !        .                  .          .
 *   .!! .::         : !            *                                     +
 *   :!! C O S M E T I C    +       .      +             * .        .
 * 
 *   TimeUIPalette - Time and Calendar UI palette for Gorm
 *   Copyright © 2006 Banlu Kemiyatorn <object@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "TimeClockEditor.h"
#include <TimeUI/TimeUI.h>
#include <GormCore/GormPrivate.h>


@implementation QSTimeControl (TimeClockEditor)
- (NSString *) editorClassName
{
	return @"TimeClockEditor";
}
@end

#if 0
@interface QSTimeControl (GormObjectAdditions)
- (NSRect) gormTitleRectForFrame:(NSRect) cellFrame
			  inView:(NSView *)controlView;
@end

@implementation QSTimeControl (GormObjectAdditions)
- (NSRect) gormTitleRectForFrame:(NSRect) cellFrame
			  inView:(NSView *)controlView
{
	NSLog(@"heredity");
	return NSMakeRect(0,0,50,50);
}

@end
#endif

#define _EO ((QSTimeControl *)_editedObject)

@implementation TimeClockEditor

- (void) sync:(id)sender
{
	[[(id<Gorm>)NSApp inspectorsManager] updateSelection];
}

- (void) mouseDown:  (NSEvent*)theEvent
{
	if (([theEvent clickCount] == 2) && [parent isOpened])
	{
		SEL oldAction = [_EO action];
		id oldTarget = [_EO target];

		[_EO setAction:NSSelectorFromString(@"sync:")];
		[_EO setTarget:self];
		[_EO mouseDown: theEvent];

		[_EO setAction:oldAction];
		[_EO setTarget:oldTarget];
	}
	else
	{
		[super mouseDown: theEvent];
	}
}
@end
