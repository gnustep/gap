#import "tile.h"

@interface GSTilePair : NSObject
{
    GSTile *fTile1, *fTile2;
    
}

- (GSTilePair *)initWithTile:(GSTile *)tileOne andTile:(GSTile *)tileTwo;
- (void)activateTiles;
- (void)release;


@end

