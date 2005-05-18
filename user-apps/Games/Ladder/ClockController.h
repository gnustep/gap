/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "Clock.h"
#include "GameVS.h"

@interface ClockController : NSObject
{
	NSTimeInterval timeprefix;
	Clock *blackClock;
	Clock *whiteClock;
	id turnButton;
	id pauseButton;
	id timePopUp;
	id clockPanel;
	id <GameTurn> _game;
	NSTimer *timer;
}
- (void) orderFrontClockPanel: (id)sender;
- (void) setTime:(id)sender;
- (void) turn:(id)sender;
- (void) setPrefixTimeInterval:(NSTimeInterval)interval;
- (void) setGame:(id <GameTurn>)game;
@end
