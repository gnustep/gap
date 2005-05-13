#include <AppKit/NSDocument.h>
#include "Board.h"

@interface GoDocument : NSDocument <BoardOwner>
{
	Board *_board;
}
@end
