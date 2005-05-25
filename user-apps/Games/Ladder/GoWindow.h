#include <AppKit/NSWindow.h>

@interface GoWindow : NSWindow
{
	id board;
}
- (void) setBoard:(id)newBoard;
- (id) board;
@end
