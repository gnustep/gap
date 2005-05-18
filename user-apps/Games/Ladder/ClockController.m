/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "ClockController.h"

/*
@interface TimeButtonCell : NSButtonCell
{
	NSTimeInterval _interval;
}

- (void) setTimeInterval:(NSTimeInterval)interval;
- (NSTimeInterval) timeInterval;
@end

@implementation TimeButtonCell
+ (TimeButtonCell *) timeButtonCellWithTimeInterval:(NSTimeInterval)interval
{
	return AUTORELEASE([[self alloc] initWithTimeInterval:interval]);
}

- (id) initWithTimeInterval:(NSTimeInterval)interval
{
	[self init];
	[self setTimeInterval:interval];
	return self;
}

- (void) setTimeInterval:(NSTimeInterval)interval
{
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
	[self setStringValue:[date description]];
	_interval = interval;
}

- (NSTimeInterval) timeInterval
{
	return _interval;
}

@end
*/

/*
@interface NSCell (Priv)
- (id) obj;
@end

@implementation NSCell (Priv)
- (id) obj
{
	NSLog(@"%d valid",_cell.has_valid_object_value);
	return _contents;
}
@end
*/

@interface ClockController (Private)
- (void) _adjustClockToGame;
- (void) _tick;
@end


@implementation ClockController

- (id) init
{
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(checkStartGame:)
			   name:GameTurnDidBeginNotification
			 object:nil];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(gameDidBecomeMain:)
			   name:GameDidBecomeMainNotification
			 object:nil];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(gameDidResignMain:)
			   name:GameDidResignMainNotification
			 object:nil];

	return self;
}

- (void) awakeFromNib
{
	NSMutableArray *cells_array;

	/* preparing clocks */
	[blackClock setNumberType:1];
	[blackClock setHandsTime:3680];
	[blackClock setShowAMPM:NO];
	[blackClock setFaceColor:[NSColor blackColor]];
	[blackClock setHandsColor:[NSColor whiteColor]];
	[blackClock setMarksColor:[NSColor whiteColor]];
	[blackClock setFrameColor:[NSColor orangeColor]];

	[whiteClock setNumberType:1];
	[whiteClock setHandsTime:3670];
	[whiteClock setShowAMPM:NO];
	[whiteClock setFrameColor:[NSColor orangeColor]];

	[blackClock setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[whiteClock setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[blackClock setDate:[NSDate dateWithTimeIntervalSince1970:0]];
	[whiteClock setDate:[NSDate dateWithTimeIntervalSince1970:0]];

	/* prepare time buttons */
	/*
	cells_array = [NSMutableArray array];
	id cell;
	id objv;
	NSFormatter *formatter;

	formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%Y"
									   allowNaturalLanguage:NO];
	objv = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:30 * 60];

	cell = AUTORELEASE([[NSButtonCell alloc] initTextCell:@"Pause"]);
	[cells_array addObject:cell];

	cell = AUTORELEASE([[NSButtonCell alloc] init]);

	[cell setFormatter:formatter];
	NSLog(@"%@ f", [cell formatter]);
	NSLog(@"%@ %@<",objv,[cell obj]);
	[cell setObjectValue:objv];
	NSLog(@"%@ %@<",objv,[cell obj]);

	[cells_array addObject:cell];
	*/


//	NSLog([formatter stringForObjectValue:[NSCalendarDate dateWithTimeIntervalSinceReferenceDate:30 * 60]]);

	[[blackClock window] setFrameAutosaveName:@"ClockPanel"];
	
}

- (void) setTime:(id)sender
{
	NSTimeInterval t = [sender tag] * 60;
	[blackClock setDate:[NSDate dateWithTimeIntervalSince1970:0]];
	[whiteClock setDate:[NSDate dateWithTimeIntervalSince1970:0]];
	[whiteClock setArcStartTime:0];
	[blackClock setArcStartTime:0];
	[whiteClock setArcEndTime:t];
	[blackClock setArcEndTime:t];
	[whiteClock setShowsArc:YES];
	[blackClock setShowsArc:YES];
}

- (void) turn:(id)sender
{
	NSMutableDictionary * dict;
	dict = [NSMutableDictionary dictionary];

	[dict setObject:@"pass"
			 forKey:@"SuggestedLocation"];

	[[NSNotificationCenter defaultCenter] postNotificationName:GameHelperSuggestionNotification
														object:_game
													  userInfo:dict];
}

- (void) setPrefixTimeInterval:(NSTimeInterval)interval
{
	timeprefix = interval;
}

- (void) gameDidResignMain:(NSNotification *)notification
{
	if ([notification object] == _game)
	{
		[self setGame:nil];
	}
	else
	{
		NSLog(@"looks like a bug");
	}
}


- (void) checkStartGame:(NSNotification *)notification
{
	//NSLog(@"check should begin %p",_game);
	if ([notification object] == _game)
	{
		[self checkGame];
	}
}

- (void) checkGame
{
	[timer invalidate];

	if (_game == nil)
	{
		timer = nil;
		[self setEnabled:NO];
	}
	else
	{
		[self setEnabled:YES];

		/* check if game has begun */
		if ([_game turnBeginDate] != nil)
		{
			//NSLog(@"launch");

			timer =  [NSTimer scheduledTimerWithTimeInterval:1.0
													  target:self
													selector:@selector(_tick)
													userInfo:nil
													 repeats:YES];
		}
		else
		{
			//NSLog(@"begin date nil");
		}

		[self _adjustClockToGame];
	}
}

- (void) gameDidBecomeMain:(NSNotification *)notification
{
	[self setGame:[notification object]];
}

- (void) setEnabled:(BOOL)enable
{
	[pauseButton setEnabled:enable];
	[turnButton setEnabled:enable];
	[timePopUp setEnabled:enable];
	[whiteClock setShowsArc:enable];
	[blackClock setShowsArc:enable];
}

- (void) setGame:(id <GameTurn>)game
{
	//NSLog(@"%p %p set",game,_game);
	if (_game == game)
	{
		return;
	}

	ASSIGN(_game, game);

	[self checkGame];
}

- (void) orderFrontClockPanel: (id)sender
{
	[clockPanel orderFront: self];
}

@end

@implementation ClockController (Private)
- (void) _adjustClockToGame
{
	if (_game)
	{
		NSCalendarDate *now = [NSCalendarDate date];
		NSTimeInterval sinceTurn;
		
		if ([_game turnBeginDate] != nil)
		{
			sinceTurn = [now timeIntervalSinceDate:[_game turnBeginDate]];
		}
		else
		{
			sinceTurn = 0;
		}

		sinceTurn += timeprefix;

		if ([_game turn] == BlackPlayerType)
		{
			[blackClock setHandsTime:[_game timeUsedForPlayerWithColorType:BlackPlayerType] + sinceTurn];
			[whiteClock setHandsTime:[_game timeUsedForPlayerWithColorType:WhitePlayerType]];
		}
		else
		{
			[blackClock setHandsTime:[_game timeUsedForPlayerWithColorType:BlackPlayerType]];
			[whiteClock setHandsTime:[_game timeUsedForPlayerWithColorType:WhitePlayerType] + sinceTurn];
		}
	}
}

- (void) _tick
{
	[self _adjustClockToGame];
}


@end
