#include "GoWindow.h"

@implementation GoWindow
- (void) setBoard:(id)newBoard
{
	ASSIGN(board,newBoard);
}

- (id) board
{
	return board;
}
@end
