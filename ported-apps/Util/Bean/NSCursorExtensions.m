/*
	NSCursorExtensions.m
	Bean
		
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#import "NSCursorExtensions.h"

@implementation NSCursor ( NSCursorExtensions )

//	because the I-Beam text cursor (for the mouse) is almost invisible against a dark background, we return
//			our own cursor here, one that has a white 'shadow' which is very visible when the background
//			of a text view is dark
//	note to self: when hijacking the behavior of a view, go to the top of the inheritance hierarchy of the 
//			class rather than trying to control it farther down the ladder
+ (NSCursor *)IBeamCursor
{
   	NSImage *whiteCursorImage = [	[[NSImage alloc]
				initWithContentsOfFile:[[NSBundle mainBundle] 
				pathForResource:@"BIbeam"
				ofType:@"tiff"
				inDirectory:nil]]	autorelease];
	NSCursor *whiteCursor = [ [ [NSCursor alloc] initWithImage:whiteCursorImage hotSpot:NSMakePoint(4.0, 8.0)] autorelease];
	return whiteCursor;
}

@end

