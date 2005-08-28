#include <AppKit/NSDocument.h>
#include "Board.h"

@interface GoDocument : NSDocument <BoardOwner>
{
	Go *_go;
	Player *_players[2];
	BOOL isMain;
}

- (void) setGo:(Go *)go;
- (Go *) go;
- (unsigned int) boardSize;
- (void) setShowHistory:(BOOL)show;
- (void) setPlayer:(Player *)player
	  forColorType:(PlayerColorType)color;
- (Player *) playerForColorType:(PlayerColorType)color;
- (PlayerColorType) turn;
- (void) setBoardSize:(unsigned int)newSize;
@end

extern NSString * GoDocumentDidBecomeMainNotification;
extern NSString * GoDocumentDidResignMainNotification;
