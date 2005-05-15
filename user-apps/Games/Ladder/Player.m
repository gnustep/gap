#include "Player.h"
#include "GameVS.h"

@implementation Player
- (id) init
{
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

- (void) playGo:(Go *)go
   forColorType:(PlayerColorType)colorType
{
}

- (void) playGo:(Go *)go
withStoneOfColorType:(PlayerColorType)colorType
		  atLocation:(GoLocation)location
{
	NSLog(@"%@ play",self);
	[go putStoneAtLocation:location];
	[go turnBegin:nil];
}

@end
