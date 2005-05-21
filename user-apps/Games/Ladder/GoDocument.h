#include <AppKit/NSDocument.h>
#include "Board.h"

@interface GoDocument : NSDocument <BoardOwner>
{
	Board *_board; // FIXME this should refer to Go, not Board.
	Player *_players[2];
}

- (unsigned int) boardSize;
- (void) setShowHistory:(BOOL)show;
- (void) setPlayer:(Player *)player
	  forColorType:(PlayerColorType)color;
- (Player *) playerForColorType:(PlayerColorType)color;
@end

extern NSString * GoDocumentDidBecomeMainNotification;
extern NSString * GoDocumentDidResignMainNotification;
