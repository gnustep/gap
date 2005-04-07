#include <Foundation/Foundation.h>
typedef enum _StoneColor
{
	BlackStone = 0,
	WhiteStone = 1,
} StoneColor;

typedef struct _GoLocation
{
	int row;
	int column;
} GoLocation;

static inline GoLocation MakeGoLocation (int row, int column)
{
	GoLocation loc;
	loc.row = row;
	loc.column = column;
	return loc;
}

@protocol Stone
- (StoneColor) stoneColor;
- (void) setColor:(StoneColor)newColor;
@end

@interface Stone : NSObject <Stone>
{
	StoneColor _color;
}
+ (Stone *) stoneWithColor:(StoneColor)color;
@end


@interface Go : NSObject
{
	Class stoneClass;
	unsigned int size;
	id *table;
}

- (void) setStoneClass:(Class)aClass;
- (void) setBoardSize:(unsigned int)newSize;
- (unsigned int) boardSize;
- (void) setStone:(id <Stone>) stone
	   atLocation:(GoLocation) location;
- (void) setStoneWithColor:(StoneColor) aColor
				atLocation:(GoLocation) location;
- (id *) table;
- (Stone *) stoneAtLocation:(GoLocation) location;

@end
