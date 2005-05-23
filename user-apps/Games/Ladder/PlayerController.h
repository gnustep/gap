#include <Foundation/Foundation.h>
#include "Player.h"

@interface PlayerController : NSObject
{
	NSMutableArray *_players;
	id addButton;
	id removeButton;
	id playerInfo;
	id playerBrowser;
}

- (NSArray *) allPlayerClasses;
- (void) addPlayerClass:(Class)newPlayerClass;
@end
