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
- (NSTimeInterval) timeUsedForPlayerWithColorType:(PlayerColorType) playerColorType;
- (void) pause;
- (void) continue;
- (NSCalendarDate *) gameBeginDate;
- (NSCalendarDate *) turnBeginDate;
- (void) setTimeUsed:(NSTimeInterval) time
forPlayerWithColorType:(PlayerColorType) playerColorType;
- (unsigned long) turnNumber;
- (void) setTurnNumber:(unsigned long)turnNumber;
- (void) passTurn;
- (void) newTurnForPlayerWithColorType:(PlayerColorType) playerColorType;
- (PlayerColorType) turn;

@end

extern NSString * GameDidBecomeMainNotification;
extern NSString * GameDidResignMainNotification;
extern NSString * GameTurnDidBeginNotification;
extern NSString * GameDidPauseNotification;
extern NSString * GameOverNotification;
extern NSString * GameHelperSuggestionNotification;

#endif /* GAMEVS_H */
