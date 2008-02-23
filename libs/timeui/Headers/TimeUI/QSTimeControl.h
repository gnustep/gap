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
#ifndef QSTIMECONTROL_H
#define QSTIMECONTROL_H

#include <AppKit/NSControl.h>

@class NSColor;

@interface QSTimeControl : NSControl

/* appearance */

- (void) setBackgroundColor:(NSColor *)aColor;
- (NSColor *) backgroundColor;
- (void) setColor:(NSColor *)aColor;
- (NSColor *) color;
- (void) setBorderColor:(NSColor *)aColor;
- (NSColor *) borderColor;
- (void) setImage:(NSImage *)backgroundImage;
- (NSImage *) image;
- (void) setFont:(NSFont *)font;
- (NSFont *) font;


/* date & time */

- (void) setDate:(NSDate *)aDate;
- (NSDate *) date;



@end

#endif /* QSTIMECONTROL_H */

// vim: filetype=objc:cinoptions={.5s,\:.5s,+.5s,t0,g0,^-2,e-2,n-2,p2s,(0,=.5s:formatoptions=croql:cindent:shiftwidth=4:tabstop=8:
