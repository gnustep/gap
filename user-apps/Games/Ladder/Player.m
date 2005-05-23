#include "Player.h"
#include "GameVS.h"

@implementation Player

static NSMutableDictionary *__playerInfo;

+ (void) initialize
{
	__playerInfo = [NSMutableDictionary new];
}

+ (Player *) player
{
	return AUTORELEASE([[self alloc] init]);
}

+ (NSDictionary *) info
{
	return [__playerInfo objectForKey:self];
}

+ (void) setInfo:(NSDictionary *)infoDict
{
	[__playerInfo setObject:infoDict
					 forKey:self];
}

- (NSDictionary *) info
{
	return [[self class] info];
}

+ (NSDictionary *) dictionaryForPath:(NSString *)path
{
	return nil;
}


- (id) init
{
	return self;
}

- (BOOL) playGo:(Go *)go
   forColorType:(PlayerColorType)colorType
{
	return NO;
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
