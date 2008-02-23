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

#include "TimeClockInspector.h"
#include <TimeUI/TimeUI.h>

@implementation QSTimeControl (TimeClockInspector)
- (NSString *) inspectorClassName
{
	return @"TimeClockInspector";
}
@end


@implementation TimeClockInspector

- (id)init
{
	self = [super init];
	if ([NSBundle loadNibNamed: @"TimeClockInspector" owner:self] == NO)
	{
		NSLog(@"fail loading TimeClockInspector");
		return nil;
	}
	return self;
}

- (void)ok:(id)sender
{
	NSLog(@"ok");
	[super ok:sender];
}

- (void)revert:(id)sender
{
	if (object == nil) return;
	[controlClock setDate:[object date]];
	[super revert:sender];
}

- (void)setClock:(id)sender
{
	[object setDate:[controlClock date]];
}

@end
