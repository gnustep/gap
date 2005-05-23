#include <Foundation/Foundation.h>
#include "Go.h"

@interface Player : NSObject
{
}

+ (Player *) player;
+ (NSDictionary *) info;
+ (void) setInfo:(NSDictionary *)infoDict;
+ (NSDictionary *) dictionaryForPath:(NSString *)path;

- (NSDictionary *) info;
- (BOOL) playGo:(Go *)go
   forColorType:(PlayerColorType)colorType;
- (void) playGo:(Go *)go
withStoneOfColorType:(PlayerColorType)colorType
		  atLocation:(GoLocation)location;
@end
