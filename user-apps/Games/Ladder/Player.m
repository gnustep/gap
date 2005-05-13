#include "Player.h"
#include "GameVS.h"

@implementation Player
- (id) init
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(turnBegin:)
												 name:GameTurnDidBeginNotification
											   object:nil];
	return self;
}

- (NSDictionary *) info
{
	return _userInfo;
}

- (void) setInfo:(NSDictionary *)infoDict
{
	ASSIGN(_userInfo, infoDict);
}

- (NSDictionary *) dictionaryForPath:(NSString *)path
{
	return [_pathDict objectForKey:path];
}

- (void) turnBegin:(NSNotification *)notification
{
	NSDictionary *dict = [notification userInfo];
	/*
	NSLog(@"turn begin with last player %@",[dict objectForKey:@"LastPlayer"]);
	NSLog(@"with stone %@",[dict objectForKey:@"Stone"]);
	NSLog(@"is turn handicap? %@",[dict objectForKey:@"IsHandicap"]);
	*/


}

- (void) putStoneWithColorType:(PlayerColorType)colorType
						  toGo:(Go *)go
					atLocation:(GoLocation)location
{
}
@end
