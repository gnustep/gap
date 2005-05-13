#include <Foundation/Foundation.h>

#ifndef GAMEVS_H
#define GAMEVS_H

typedef enum _PlayerColorType
{
	BlackPlayerType = 0,
	WhitePlayerType = 1,
	EmptyPlayerType = 2,
} PlayerColorType;

@protocol GameTurn
- (NSTimeInterval) timeUsedForPlayerColorType:(PlayerColorType) playerColorType;
- (void) pause;
- (void) continue;
- (NSCalendarDate *) gameBeginDate;
- (NSCalendarDate *) turnBeginDate;
- (void) setTimeUsed:(NSTimeInterval) time
  forPlayerColorType:(PlayerColorType) playerColorType;
- (unsigned long) turnNumber;
- (void) setTurnNumber:(unsigned long)turnNumber;
- (void) passTurn;
- (void) newTurnForPlayer:(PlayerColorType) playerColorType;
- (PlayerColorType) turn;

@end

extern NSString *GameDidBecomeMainNotification;
extern NSString *GameDidResignMainNotification;
extern NSString *GameTurnDidBeginNotification;

#endif /* GAMEVS_H */
