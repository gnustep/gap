#include <Foundation/Foundation.h>
#include "Player.h"

@interface GNUGoPlayer : Player
{
	NSTask *_gnugo;
	NSPipe *_eventPipe;
	NSPipe *_commandPipe;
	Go *currentGo;
}

@end
