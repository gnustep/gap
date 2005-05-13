#include "Go.h"
#include "Player.h"

@implementation Stone

- (NSString*) description
{
	return [NSString stringWithFormat: @"<%@: %@>",
		   NSStringFromClass([self class]), _colorType == BlackPlayerType?@"Black":@"White"];
}


+ (Stone *) stoneWithPlayerColorType:(PlayerColorType)colorType
{
	id stone = AUTORELEASE([self new]);
	[stone setPlayerColorType:colorType];
	return stone;
}

- (PlayerColorType) playerColorType
{
	return _colorType;
}

- (void) setPlayerColorType:(PlayerColorType)newColorType
{
	_colorType = newColorType;
}

- (void) setOwner:(Go *)owner
{
	__owner = owner;
}

- (Go *) owner
{
	return __owner;
}

- (GoLocation) location
{
	if (__owner)
	{
		return [__owner locationForStone:self];
	}
	else
	{
		return GoNoLocation;
	}
}

@end

@implementation GoTurn
@end

@class StoneUI;
@implementation Go

- (void) awakeFromNib
{
	[self setBoardSize:19];
//	[self setHandicap:100];

	/*
	int r,c;

	[self setBoardSize:5 + random()%15];
	[self setStoneClass:[StoneUI class]];

	for (r = 1; r <= size; r++)
	for (c = 1; c <= size; c++)
	{
		if (random()%2)
		{
			[self setStoneWithPlayerColorType:random()%2
								   atLocation:MakeGoLocation(r,c)];
		}
	}
	*/

	[self _setupGNUGo];
}

/*
- (id) retain
{
	NSLog(@"retain Go %d",[self retainCount]);
	return [super retain];
}

- (void) release
{
	NSLog(@"release Go %d",[self retainCount]);
	[super release];
}
*/

- (id) init
{
//	NSLog(@"init %d",[self retainCount]);
	stoneClass = [Stone class];
	turn = BlackPlayerType;
	[self setBoardSize:19];
	return self;
}

- (void) dealloc
{
	NSLog(@"Go %@ dealloc",self);
	[self setBoardSize:1];
	free(_boardTable);
	RELEASE(_players[BlackPlayerType]);
	RELEASE(_players[WhitePlayerType]);
	RELEASE(_startTurn);
	RELEASE(_gameBeginDate);
	RELEASE(_turnBeginDate);
	[_gnugo terminate];
	RELEASE(_gnugo);

	[super dealloc];
}

- (void) setStoneClass:(Class)aClass
{
	stoneClass = aClass;
}

- (void) clearBoard
{
	int i,j,offset;

	if (_boardTable != NULL)
	{
		for (i = 0; i < size; i++)
		{
			for (j = 0; j < size; j++)
			{
				offset = i * size + j;
				if (_boardTable[offset] != nil)
				{
					[_boardTable[offset] setOwner:nil];
					DESTROY(_boardTable[offset]);
				}
			}
		}
	}
}

- (void) setBoardSize:(unsigned int)newSize;
{
	int i,j;

	if (_boardTable != NULL)
	{
		[self clearBoard];
		free(_boardTable);
	}

	size = newSize;

	_boardTable = malloc(sizeof(id) * size * size);
	bzero(_boardTable, sizeof(id) * size * size);

}

- (unsigned int) boardSize;
{
	return size;
}

- (void) setHandicap:(unsigned int)handicap
{
	NSAssert(_turnNumber == 0, @"Set handicap during the game");
	_handicapLeft = handicap;
}

- (void) newTurnForPlayerColorType:(PlayerColorType) playerColorType
{
	_turnNumber++;
}

- (void) _setupGNUGo
{
	if (_gnugo == nil)
	{
		ASSIGN(_gnugo, [[NSTask alloc] init]);
		ASSIGN(_eventPipe, [NSPipe pipe]);
		ASSIGN(_commandPipe, [NSPipe pipe]);
		/*

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(GNUGoEvent:)
													 name:NSFileHandleDataAvailableNotification
												   object:[_eventPipe fileHandleForReading]];
		[[_eventPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
		*/

		[_gnugo setStandardOutput:_eventPipe];
		[_gnugo setStandardInput:_commandPipe];
		[_gnugo setLaunchPath:@"gnugo"];
		[_gnugo setArguments:[NSArray arrayWithObjects:@"--mode",@"gtp",nil]];
		[_gnugo launch];
		NSLog(@"launch gnugo");

	}
}

- (NSString *) runGTPCommand:(NSString *)command
{
	NSString *str;
	id fh  = [_commandPipe fileHandleForWriting];
	NSData *data = [[command stringByAppendingString:@"\n"] dataUsingEncoding:NSASCIIStringEncoding];

	[fh writeData:data];

	fh = [_eventPipe fileHandleForReading];

	str = @"";

	while ((data = [fh availableData]))
	{
		char *bytes = [data bytes];
		unsigned offset = [data length];
		str = [str stringByAppendingString:
			AUTORELEASE([[NSString alloc] initWithData:data
											  encoding:NSASCIIStringEncoding])];
		if (bytes[offset - 2] == 0x0A && bytes[offset - 1] == 0x0A)
		{
			break;
		}
	}

	return str;
}

static NSString *columnstr[] = {@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T"};

static NSString * __string_for_go_location(GoLocation loc)
{
	return [NSString stringWithFormat:@"%@%d",
		   columnstr[loc.column-1],
		   loc.row];
}

static GoLocation __go_location_for_string(NSString *str)
{
	GoLocation retloc;
	int i;

	if (str == nil || [str length] < 2)
	{
		return GoNoLocation;
	}

	NSString *substr = [str substringToIndex:1];

	for (i=0;i<19;i++)
	{
		if ([substr isEqualToString:columnstr[i]])
		{
			retloc.column = i + 1;
			break;
		}
	}
	substr = [str substringFromIndex:1];
	retloc.row = [substr intValue];

	return retloc;
}

static BOOL __check_state(NSString *str)
{
	if ([str characterAtIndex:0] == '=')
	{
		return YES;
	}
	return NO;
}

- (void) _syncBoardWithGNUGo
{
	NSString *str;
	NSEnumerator *en;
	NSArray *items;
	GoLocation loc;
	id *newTable;
	id stone;
	int offset,i;
	NSString *cmdList[] = {@"list_stones black",@"list_stones white"};

	newTable = malloc(sizeof(id) * size * size);
	bzero(newTable, sizeof(id) * size * size);

	for (i = 0; i < 2; i++)
	{
		str = [self runGTPCommand:cmdList[i]];
		if (__check_state(str))
		{
			str = [str substringWithRange:NSMakeRange(2,[str length]-4)];
			items = [str componentsSeparatedByString:@" "];
			en = [items objectEnumerator];
			while ((str = [en nextObject]))
			{
				loc = __go_location_for_string(str);

				if (GoIsLocation(loc))
				{
					offset = (loc.row - 1) * size + (loc.column - 1);
					stone = [self stoneAtLocation:loc];
					if (stone)
					{
						ASSIGN(newTable[offset],stone);
					}
					else
					{
						NSLog(@"alertttttt");
					}
				}
			}
		}
	}

	[self clearBoard];
	free(_boardTable);
	_boardTable = newTable;
}

- (void) setStone:(id <Stone>) stone
	   atLocation:(GoLocation) location
			 date:(NSCalendarDate *)turnTime
{
	int offset = (location.row - 1) * size + (location.column - 1);
	NSMutableDictionary * dict;

	NSString *cmdString;

	cmdString = [NSString stringWithFormat:@"play %@ %@",[stone playerColorType] == BlackPlayerType?@"black":@"white",__string_for_go_location(location)];


	if (__check_state([self runGTPCommand:cmdString]) == NO)
	{
		NSLog(@"set stone fail");
		return;
	}
	else
	{
//		NSLog([self runGTPCommand:@"showboard"]);
	}

	/*
	if ([stone playerColorType] == 0)
	{
		NSLog(@"SHITHAPPENED");
	}
	*/

	dict = [NSMutableDictionary dictionary];

	if (_players[turn])
	{
		[dict setObject:_players[turn]
				 forKey:@"LastPlayer"];
	}

	if (isPause)
	{
		[self continue];
	}

	if (_turnBeginDate == nil)
	{
		_turnBeginDate = [turnTime copy];
		_gameBeginDate = [turnTime copy];
	}

	timeUsed[turn] = timeUsed[turn] + [turnTime timeIntervalSinceDate:_turnBeginDate];

	if (stone)
	{
		[dict setObject:stone
				 forKey:@"Stone"];

		[stone setOwner:self];
		if ([stone playerColorType] == BlackPlayerType)
		{
			turn = WhitePlayerType;
			ASSIGN(_boardTable[offset], stone);
		}
		else
		{
			turn = BlackPlayerType;
			ASSIGN(_boardTable[offset], stone);
		}
	}
	else
	{
		if (turn == BlackPlayerType)
		{
			turn = WhitePlayerType;
		}
		else
		{
			turn = BlackPlayerType;
		}
	}

	if (_handicapLeft > 0)
	{
		[dict setObject:@"YES"
				 forKey:@"IsHandicap"];

		_handicapLeft--;
		if (_handicapLeft > 0)
		{
			turn = BlackPlayerType;
		}
	}

	ASSIGN(_turnBeginDate, turnTime);

	[self _syncBoardWithGNUGo];

	[dict setObject:turn == BlackPlayerType?@"BlackStone":@"WhiteStone"
			 forKey:@"CurrentTurn"];

	[[NSNotificationCenter defaultCenter] postNotificationName:GameTurnDidBeginNotification
														object:_players[turn]
													  userInfo:dict];
	[self newTurnForPlayerColorType:turn];
}

- (void) setStone:(id <Stone>) stone
	   atLocation:(GoLocation) location
{
	[self setStone:stone
		atLocation:location
			  date:[NSCalendarDate calendarDate]];
}

- (void) setStoneWithPlayerColorType:(PlayerColorType) aColorType
						  atLocation:(GoLocation) location
{
	[self setStone:[stoneClass stoneWithPlayerColorType:aColorType]
		atLocation:location];
}

- (void) putStoneAtLocation:(GoLocation) location
{
	NSLog(@"TURN %d",turn);
	[self setStoneWithPlayerColorType:turn
						   atLocation:location];
}

- (void) passTurn
{
	[self setStone:nil
		atLocation:MakeGoLocation(0,0)];
}


- (unsigned long) turnNumber
{
	return _turnNumber;
}

/* for undoing */
- (void) setTurnNumber:(unsigned long)turnNumber
{
	_turnNumber = turnNumber;
}

- (id *) board
{
	return _boardTable;
}

- (Stone *) stoneAtLocation:(GoLocation) location
{
	return _boardTable[(location.row - 1) * size + (location.column - 1)];
}

- (GoLocation) locationForStone:(id <Stone>) stone
{
	int i,j;
	if (_boardTable != NULL)
	{
		for (i = 0; i < size; i++)
		{
			for (j = 0; j < size; j++)
			{
				int offset;

				offset = i * size + j;
				if (_boardTable[offset] == stone)
				{
					return MakeGoLocation(i+1, j+1);
				}
			}
		}
	}

	return GoNoLocation;
}

- (PlayerColorType) turn
{
	return turn;
}

- (void) setBlackPlayer:(Player *)blackPlayer
			whitePlayer:(Player *)whitePlayer
{
	ASSIGN(_players[BlackPlayerType], blackPlayer);
	ASSIGN(_players[WhitePlayerType], whitePlayer);
}

- (void) setTimeUsed:(NSTimeInterval) time
  forPlayerColorType:(PlayerColorType) playerColorType
{
	timeUsed[playerColorType] = time;
}

- (NSTimeInterval) timeUsedForPlayerColorType:(PlayerColorType) playerColorType
{
	return timeUsed[playerColorType];
}

- (void) pause
{
	isPause = YES;
	NSCalendarDate * turnTime = [NSCalendarDate calendarDate];

	timeUsed[turn] = timeUsed[turn] + [turnTime timeIntervalSinceDate:_turnBeginDate];
}

- (void) continue
{
	NSCalendarDate * turnTime = [NSCalendarDate calendarDate];
	isPause = NO;
	ASSIGN(_turnBeginDate, turnTime);
}

- (NSCalendarDate *) gameBeginDate
{
	return _gameBeginDate;
}

- (NSCalendarDate *) turnBeginDate
{
	return _turnBeginDate;
}

@end
