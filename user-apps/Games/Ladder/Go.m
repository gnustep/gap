#include "Go.h"

@implementation Stone

- (NSString*) description
{
	return [NSString stringWithFormat: @"<%@: %@>",
		   NSStringFromClass([self class]), _color == BlackStone?@"Black":@"White"];
}


+ (Stone *) stoneWithColor:(StoneColor)color
{
	id stone = AUTORELEASE([self new]);
	[stone setColor:color];
	return stone;
}

- (StoneColor) stoneColor
{
	return _color;
}

- (void) setColor:(StoneColor)newColor
{
	_color = newColor;
}

@end

@implementation Go
- (id) init
{
	self = [super init];
	stoneClass = [Stone class];
	return self;
}

- (void) setStoneClass:(Class)aClass
{
	stoneClass = aClass;
}

- (void) setBoardSize:(unsigned int)newSize;
{
	int i,j;

	if (table != NULL)
	{
		for (i = 0; i < size; i++)
		{
			for (j = 0; j < size; j++)
			{
				int offset;

				offset = i * size + j;
				if (table[offset] != nil)
				{
					RELEASE(table[offset]);
				}
			}
		}

		free(table);
	}

	size = newSize;

	table = malloc(sizeof(id) * size * size);
	bzero(table, sizeof(id) * size * size);

}

- (unsigned int) boardSize;
{
	return size;
}

- (void) setStone:(id <Stone>) stone
	   atLocation:(GoLocation) location
{
	int offset = (location.row - 1) * size + (location.column - 1);
	ASSIGN(table[offset], stone);
	/*
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GoTurned"
														object:self
													  userInfo:dict];
													  */
}

- (void) setStoneWithColor:(StoneColor) aColor
				atLocation:(GoLocation) location
{
	[self setStone:[stoneClass stoneWithColor:aColor]
		atLocation:location];
}

- (id *) table
{
	return table;
}

- (Stone *) stoneAtLocation:(GoLocation) location
{
	return table[(location.row - 1) * size + (location.column - 1)];
}

@end
