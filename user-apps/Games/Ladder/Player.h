#include <Foundation/Foundation.h>
#include "Go.h"

@interface Player : NSObject
{
	NSMutableDictionary *_pathDict;
	NSMutableDictionary *_userInfo;
}

- (NSDictionary *) info;
- (void) setInfo:(NSDictionary *)infoDict;
- (NSDictionary *) dictionaryForPath:(NSString *)path;
- (BOOL) playGo:(Go *)go
   forColorType:(PlayerColorType)colorType;
- (void) playGo:(Go *)go
withStoneOfColorType:(PlayerColorType)colorType
		  atLocation:(GoLocation)location;
@end
