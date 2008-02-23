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
#ifndef _QingShan_H_QSTimeClockCell
#define _QingShan_H_QSTimeClockCell

#include <AppKit/NSActionCell.h>

typedef enum
{
  QSTimeAnalogClock = 0,
  QSTimeDigitalClock = 1
} QSTimeClockType;

typedef enum
{
  QSTimeAnalogClockNoHand = 0,
  QSTimeAnalogClockSecondHand = 1 << 0,
  QSTimeAnalogClockMinuteHand = 1 << 1,
  QSTimeAnalogClockHourHand = 1 << 2,
} QSTimeAnalogClockHand;

@interface QSTimeAnalogClockCellStyle : NSObject <NSCoding>
{
}
@end

@interface QSTimeClockCell : NSActionCell <NSCoding>
{
	NSDate *_date;
}

- (void) setBackgroundColor:(NSColor *)aColor;
- (NSColor *) backgroundColor;
- (void) setColor:(NSColor *)aColor;
- (NSColor *) color;
- (void) setBorderColor:(NSColor *)aColor;
- (NSColor *) borderColor;
- (void) setDate:(NSDate *)date;
- (NSDate *) date;
- (void) setFont:(NSFont *)font;
- (NSFont *) font;
@end

@interface QSTimeAnalogClockCell : QSTimeClockCell <NSCoding>
{
	QSTimeAnalogClockCellStyle *_style;
	NSTimeInterval _offset;
	QSTimeAnalogClockHand _selectedHand_;
}

+ (BOOL) prefersTrackingUntilMouseUp;

// replace with initWithClockType: which return the actual kind of cell.
/*
- (void) setClockType:(QSTimeClockType)clockType;
- (QSClockType) clockType;
*/

/*
- (void) setTickIncrementInterval:(NSTimeInterval)anInterval;
- (NSTimeInterval) tickIncrementInterval;
*/
@end


#endif

/* TODO : cache panel buffer in factory class's hash (NSStringFromRect) */

// vim: filetype=objc:cinoptions={.5s,\:.5s,+.5s,t0,g0,^-2,e-2,n-2,p2s,(0,=.5s:formatoptions=croql:cindent:shiftwidth=4:tabstop=8:
