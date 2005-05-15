#include <AppKit/NSDocument.h>
#include "Board.h"

@interface GoDocument : NSDocument <BoardOwner>
{
	Board *_board;
	Player *_players[2];
}

- (void) setPlayer:(Player *)player
	  forColorType:(PlayerColorType)color;
@end
