#ifndef GO_H
#define GO_H

#include <Foundation/Foundation.h>

#include "GameVS.h"

typedef struct _GoLocation
{
	int row;
	int column;
} GoLocation;

static const GoLocation GoNoLocation;

static BOOL GoIsLocation (GoLocation location)
{
	if (location.row == 0 || location.column == 0)
	{
		return NO;
	}

	return YES;
}

static inline GoLocation MakeGoLocation (int row, int column)
{
	GoLocation loc;
	loc.row = row;
	loc.column = column;
	return loc;
}

@class Go;

@protocol Stone
- (PlayerColorType) colorType;
- (void) setColorType:(PlayerColorType)newColorType;
- (void) setOwner:(Go *)owner;
- (Go *) owner;
- (GoLocation) location;
- (void) setTurnNumber:(unsigned int) num;
- (unsigned int) turnNumber;
@end

@interface Stone : NSObject <Stone>
{
	Go *__owner;
	PlayerColorType _colorType;
	unsigned int turnno;
}
+ (Stone *) stoneWithColorType:(PlayerColorType)color;
@end

@interface GoTurn : NSObject
{
	GoTurn *__previous;
	GoLocation location;
	NSMutableArray *nextList;
	NSTimeInterval timeIntervalSincePreviousTurn;
	NSTimeInterval timeIntervalUsedForTurn;
}

@end

@class Player;

@interface Go : NSObject <GameTurn>
{
	Class stoneClass;
	unsigned int size;
	id *_boardTable;
	PlayerColorType turn;
	Player * _players[2];

	GoTurn * __currentTurn;
	GoTurn * _startTurn;

	NSCalendarDate *_gameBeginDate;
	NSCalendarDate *_turnBeginDate;
	BOOL isPause;
	NSTimeInterval timeUsed[2];
	unsigned long _turnNumber;
	int _handicapLeft;
	NSTask *_gnugo;
	NSPipe *_eventPipe;
	NSPipe *_commandPipe;
}

- (void) setStoneClass:(Class)aClass;
- (void) setBoardSize:(unsigned int)newSize;
- (unsigned int) boardSize;
//- (void) setHandicap:(unsigned int)handicap;
- (void) setStone:(id <Stone>) stone
	   atLocation:(GoLocation) location
			 date:(NSCalendarDate *)turnTime;
- (void) setStone:(id <Stone>) stone
	   atLocation:(GoLocation) location;
- (void) setStoneWithColorType:(PlayerColorType) aColorType
					atLocation:(GoLocation) location;
- (void) putStoneAtLocation:(GoLocation) location;
- (id *) board;
- (Stone *) stoneAtLocation:(GoLocation) location;
- (GoLocation) locationForStone:(id <Stone>) stone;

- (BOOL) printSGFToFile:(NSString *)path;
- (BOOL) loadSGFFile:(NSString *)path;

- (void) clearBoard;
- (void) turnBegin:(NSCalendarDate *)turnDate;
@end

extern NSString * GoStoneNotification;
#endif
