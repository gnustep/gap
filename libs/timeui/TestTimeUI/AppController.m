/*
 *        .::!!!!::.       *     +               .              *      .
 *     .:!' .:::::. ':                *                    .
 *    :!: ::'      ': !        .                  .          .
 *   .!! .::         : !            *                                     +
 *   :!! C O S M E T I C    +       .      +             * .        .
 * 
 *   TestTimeUI - a testing application for TimeUI framework
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

#include <AppKit/AppKit.h>
#include <TimeUI/TimeUI.h>
#include "AppController.h"

#define NUMBER_OF_CLOCK 12

@implementation AppController

static NSMutableArray *cellArray;
static NSTimer *timer;

- (void) awakeFromNib
{
	cellArray = [NSMutableArray array];
	RETAIN(cellArray);

	int i;
	for (i = 0; i < NUMBER_OF_CLOCK; i++)
	{
		QSTimeAnalogClockCell *clockCell = [[QSTimeAnalogClockCell alloc] init];
		[cellArray addObject:clockCell];
		RELEASE(clockCell);
	}

	[clockMatrix setCellSize:NSMakeSize(50,70)];
	[clockMatrix addRowWithCells:cellArray];
	[clockMatrix sizeToCells];
}

-(void) applicationWillFinishLaunching: (NSNotification *)not
{
}

-(void) applicationDidFinishLaunching: (NSNotification *)not
{
	NSInvocation *inv;
	inv = [NSInvocation invocationWithMethodSignature:
		[self methodSignatureForSelector:@selector(tick)]];
	[inv setSelector:@selector(tick)];
	[inv setTarget:self];
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 invocation:inv repeats:YES];

}

- (void) tick
{
	NSEnumerator *en;
	en = [cellArray objectEnumerator];
	id cell;
	NSTimeInterval offset = 0.;
	while ((cell = [en nextObject]))
	{
		[cell setDate:[[NSDate date] addTimeInterval:offset]];
		offset += 3610;
	}
	[clockMatrix setNeedsDisplay:YES];
}


@end
