#include "GNUGoPlayer.h"

@implementation GNUGoPlayer

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

- (void) GNUGoEvent:(NSNotification *)notification
{
	id fh = [_eventPipe fileHandleForReading];
	NSString *str = @"";
	NSData *data;

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
	str = [str substringWithRange:NSMakeRange(2,[str length]-4)];
	NSLog(@"play %@",str);
	[self playGo:currentGo
		withStoneOfColorType:[currentGo turn]
				  atLocation:__go_location_for_string(str)];

}

- (id) init
{
	ASSIGN(_gnugo, [[NSTask alloc] init]);
	ASSIGN(_eventPipe, [NSPipe pipe]);
	ASSIGN(_commandPipe, [NSPipe pipe]);
	[_gnugo setStandardOutput:_eventPipe];
	[_gnugo setStandardInput:_commandPipe];
	[_gnugo setLaunchPath:@"gnugo"];
	[_gnugo setArguments:[NSArray arrayWithObjects:@"--mode",@"gtp",nil]];
	[_gnugo launch];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(GNUGoEvent:)
												 name:NSFileHandleDataAvailableNotification
											   object:[_eventPipe fileHandleForReading]];

	return self;
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

- (BOOL) playGo:(Go *)go
   forColorType:(PlayerColorType)colorType
{
	int i,j;

	int boardSize = [go boardSize];

	currentGo = go;

	NSString *str;
	NSData *data;

	[self runGTPCommand:@"clear_board"];
	[self runGTPCommand:[NSString stringWithFormat:@"boardsize %d",boardSize]];

	/* FIXME should be smarter than this */
	for (i = 1; i <= boardSize; i ++)
	for (j = 1; j <= boardSize; j ++)
	{
		Stone *stone = [go stoneAtLocation:MakeGoLocation(i,j)];
		if (stone != nil)
		{
			str = @"";
			if ([stone colorType] == BlackPlayerType)
			{
				str = [NSString stringWithFormat:@"play black %@",__string_for_go_location(MakeGoLocation(i,j))];
			}
			else
			{
				str = [NSString stringWithFormat:@"play white %@",__string_for_go_location(MakeGoLocation(i,j))];
			}
			[self runGTPCommand:str];
		}
	}

	data = [[NSString stringWithFormat:@"genmove %@\n",colorType == BlackPlayerType?@"black":@"white"] dataUsingEncoding:NSASCIIStringEncoding];

	[[_commandPipe fileHandleForWriting] writeData:data];

	[[_eventPipe fileHandleForReading] waitForDataInBackgroundAndNotify];

	return YES;
}
@end
