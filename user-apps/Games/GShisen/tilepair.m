#include "tilepair.h"

@implementation GSTilePair

- (GSTilePair *)initWithTile:(GSTile *)tileOne andTile:(GSTile *)tileTwo
{
    fTile1 = tileOne;
    fTile2 = tileTwo;
    return self;
}

- (void)activateTiles
{
    [fTile1 unselect];
    [fTile1 activate];
    [fTile2 unselect];
    [fTile2 activate];
}

- (void)release
{
    fTile1 = nil;
    fTile2 = nil;
    [super release];
}


@end
