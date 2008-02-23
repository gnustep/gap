/*
 *        .::!!!!::.       *     +               .              *      .
 *     .:!' .:::::. ':                *                    .
 *    :!: ::'      ': !        .                  .          .
 *   .!! .::         : !            *                                     +
 *   :!! C O S M E T I C    +       .      +             * .        .
 * 
 *   TimeUI - Time and Calendar UI framework for GNUstep
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

#include "TimeUI/QSTimeControl.h"
#include "TimeUI/QSTimeClockCell.h"

#include <Foundation/NSUserDefaults.h>
#include <Foundation/NSDate.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSActionCell.h>


@implementation QSTimeControl

static Class __qs_clock_cell_class;

+ (void) initialize
{
	if (self == [QSTimeControl class])
	{
		[self setCellClass: [QSTimeAnalogClockCell class]];
	}
}

+ (void) setCellClass:(Class)aClass
{
	__qs_clock_cell_class = aClass;
}


+ (Class) cellClass
{
	return __qs_clock_cell_class;
}

- (id) initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];

	[_cell setDate:[NSDate date]];

	return self;
}

/* appearance */

- (void) setBackgroundColor:(NSColor *)aColor
{
	[_cell setBackgroundColor:aColor];
}

- (NSColor *) backgroundColor

{
	return [_cell backgroundColor];
}

- (void) setColor:(NSColor *)aColor
{
	[_cell setColor:aColor];
}

- (NSColor *) color
{
	return [_cell color];
}

- (void) setBorderColor:(NSColor *)aColor
{
	[_cell setBorderColor:aColor];
}

- (NSColor *) borderColor
{
	return [_cell borderColor];
}

- (void) setImage:(NSImage *)backgroundImage
{
	[_cell setImage:backgroundImage];
}

- (NSImage *) image
{
	return [_cell image];
}

- (void) setFont:(NSFont *)font
{
	[_cell setFont:font];
}

- (NSFont *) font
{
	return [_cell font];
}

- (void) setDate:(NSDate *)date
{
	[_cell setDate:date];
	[self setNeedsDisplay:YES];
}

- (NSDate *) date
{
	return [_cell date];
}

/*
- (void) mouseDown:(NSEvent *)theEvent
{
	if ([_cell isEnabled])
	{
	}
}
*/

- (void) awakeFromNib
{
}

@end

// vim: filetype=objc:cinoptions={.5s,\:.5s,+.5s,t0,g0,^-2,e-2,n-2,p2s,(0,=.5s:formatoptions=croql:cindent:shiftwidth=4:tabstop=8:
