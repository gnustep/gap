#include "GoDocument.h"
#include "GNUGoPlayer.h"
#include "GoWindow.h"
#include "PlayerController.h"
#include "AppController.h"

NSString * GoDocumentDidBecomeMainNotification = @"GoDocumentDidBecomeMainNotification";
NSString * GoDocumentDidResignMainNotification = @"GoDocumentDidResignMainNotification";

@implementation GoDocument

- (id) init
{
	self = [super init];

	[self setGo:AUTORELEASE([[Go alloc] init])];

	return self;
}

- (void) setBoardSize:(unsigned int)newSize
{
	[_go clearBoard];
	[_go setBoardSize:newSize];
	[self setGo:_go]; /* broadcast the change */
}

- (unsigned int) boardSize
{
	return [_go boardSize];
}

- (Go *) go
{
	return _go;
}

- (void) setGo:(Go *)go
{
	ASSIGN(_go, go);
	[go setStoneClass:[StoneUI class]];

	NSEnumerator *en = [[self windowControllers] objectEnumerator];
	NSWindowController *winController;
	GoWindow *window;
	Class goWinClass = [GoWindow class];

	while ((winController = [en nextObject]))
	{
		window = (GoWindow *)[winController window];
		if ([window isMemberOfClass:goWinClass])
		{
			[[window board] setGo:go];
		}
	}

	if (_go != nil && isMain)
	{
		[[NSNotificationCenter defaultCenter]
			postNotificationName:GameDidBecomeMainNotification
						  object:_go];
	}
}

- (void) setShowHistory:(BOOL)show
{
	NSEnumerator *en = [[self windowControllers] objectEnumerator];
	NSWindowController *winController;
	GoWindow *window;
	Class goWinClass = [GoWindow class];

	while ((winController = [en nextObject]))
	{
		window = (GoWindow *)[winController window];
		if ([window isMemberOfClass:goWinClass])
		{
			[[window board] setShowHistory:show];
		}
	}

}

- (Player *) playerForColorType:(PlayerColorType)color
{
	return _players[color];
}

- (PlayerColorType) turn
{
	return [_go turn];
}

- (void) awakeFromNib
{
	NSArray *parray = [(PlayerController *)[[NSApp delegate] playerController] allPlayerClasses];

	ASSIGN(_players[BlackPlayerType], [[parray objectAtIndex:0] player]);
	ASSIGN(_players[WhitePlayerType], [[parray objectAtIndex:1] player]);

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(turnBegin:)
			   name:GameTurnDidBeginNotification
			 object:_go];
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
	if (_go != nil)
	{
		[[NSNotificationCenter defaultCenter]
			postNotificationName:GameDidBecomeMainNotification
						  object:_go];
	}

	[[NSNotificationCenter defaultCenter]
		postNotificationName:GoDocumentDidBecomeMainNotification
					  object:self];
	isMain = YES;
}

- (void) windowDidResignMain: (NSNotification*)aNotification
{
	if (_go != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:GameDidResignMainNotification
															object:_go];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:GoDocumentDidResignMainNotification
														object:self];
	isMain = NO;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
	Class goWinClass = [GoWindow class];
	GoWindow *window = [windowController window];
	if ([window isMemberOfClass:goWinClass])
	{
		[[window board] setGo:_go];
	}
}

- (void) turnBegin:(NSNotification *)notification
{
	Go *go = [notification object];
	NSAssert(_go == go, @"Got notification for non-registered object");

	PlayerColorType turn = [go turn];
	if ([_players[turn] playGo:go
				  forColorType:turn] == NO)

	{
		NSEnumerator *en = [[self windowControllers] objectEnumerator];
		NSWindowController *winController;
		GoWindow *window;
		Class goWinClass = [GoWindow class];

		while ((winController = [en nextObject]))
		{
			window = (GoWindow *)[winController window];
			if ([window isMemberOfClass:goWinClass])
			{
				[[window board] setEditable:YES];
			}
		}
	}
}

- (void) playerShouldPutStoneAtLocation:(GoLocation)location
{
	NSEnumerator *en = [[self windowControllers] objectEnumerator];
	NSWindowController *winController;
	GoWindow *window;
	Class goWinClass = [GoWindow class];

	while ((winController = [en nextObject]))
	{
		window = (GoWindow *)[winController window];
		if ([window isMemberOfClass:goWinClass])
		{
			[[window board] setEditable:NO];
		}
	}

	PlayerColorType turn = [_go turn];

	[_players[turn] playGo:_go
	  withStoneOfColorType:turn
				atLocation:location];
}

- (void) dealloc
{
	RELEASE(_players[BlackPlayerType]);
	RELEASE(_players[WhitePlayerType]);
	RELEASE(_go);
	[super dealloc];
}

/*
- (NSFileWrapper *)fileWrapperRepresentationOfType:(NSString *)type
{
	if ([type isEqualToString:@"sgf"])
	{
	}
	else
	{
		return [super fileWrapperRepresentationOfType:type];
	}
}
*/

- (NSString *) windowNibName
{
	return @"GoDocument";
}

//- (void) windowControllerDidLoadNib:(NSWindowController *) aController


- (NSData *)dataRepresentationOfType:(NSString *)aType
{
	NSAssert([aType isEqualToString:@"sgf"], @"Unknown type");

	char path[30] = "/tmp/Ladder.XXXXXX";
	/* create a temp file */
	int fd = -1;
	fd = mkstemp(path);
	NSAssert(fd != -1, @"Cannot create temporary file");

	NSAssert([_go printSGFToFile:[NSString stringWithCString:path]], @"Error saving file");

	NSData *retData = [NSData dataWithContentsOfFile:[NSString stringWithCString:path]];

	unlink(path);
	close(fd);

	return retData;
}


- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	NSAssert([aType isEqualToString:@"sgf"], @"Unknown type");

	char path[30] = "/tmp/Ladder.XXXXXX";
	/* create a temp file */
	int fd = -1;
	fd = mkstemp(path);
	NSAssert(fd != -1, @"Cannot create temporary file");

	[data writeToFile:[NSString stringWithCString:path]
		   atomically:NO];

	[_go loadSGFFile:[NSString stringWithCString:path]];
	NSAssert([_go loadSGFFile:[NSString stringWithCString:path]], @"Error loading file");

	unlink(path);
	close(fd);

	/* TODO should analyze the data if there is any attached plist */

	return YES;

}

- (void) setPlayer:(Player *)player
	  forColorType:(PlayerColorType)color
{
	ASSIGN(_players[color], player);

	PlayerColorType turn = [_go turn];

	if (turn == color)
	{
		NSEnumerator *en = [[self windowControllers] objectEnumerator];
		NSWindowController *winController;
		GoWindow *window;
		Class goWinClass = [GoWindow class];
		BOOL willPlay = [_players[turn] playGo:_go
								  forColorType:turn];

		while ((winController = [en nextObject]))
		{
			window = (GoWindow *)[winController window];
			if ([window isMemberOfClass:goWinClass])
			{
				[[window board] setEditable:!willPlay];
			}
		}
	}
}

@end
