#include "GoDocument.h"
#include "GNUGoPlayer.h"

NSString * GoDocumentDidBecomeMainNotification = @"GoDocumentDidBecomeMainNotification";
NSString * GoDocumentDidResignMainNotification = @"GoDocumentDidResignMainNotification";

@implementation GoDocument

- (id) init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

- (void) setBoardSize:(unsigned int)newSize
{
	[[_board go] clearBoard];
	[[_board go] setBoardSize:newSize];
	[_board setGo:[_board go]];
}

- (unsigned int) boardSize
{
	return [[_board go] boardSize];
}

- (void) setShowHistory:(BOOL)show
{
	[_board setShowHistory:show];
}

- (Player *) playerForColorType:(PlayerColorType)color
{
	return _players[color];
}

- (void) awakeFromNib
{
	NSArray *parray = [[[NSApp delegate] playerController] allPlayerClasses];

	ASSIGN(_players[BlackPlayerType], [[parray objectAtIndex:0] player]);
	ASSIGN(_players[WhitePlayerType], [[parray objectAtIndex:1] player]);

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(turnBegin:)
			   name:GameTurnDidBeginNotification
			 object:[_board go]];
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:GameDidBecomeMainNotification
														object:[_board go]];
	[[NSNotificationCenter defaultCenter] postNotificationName:GoDocumentDidBecomeMainNotification
														object:self];
	NSLog(@"%@ %d", [_board go],[[_board go] retainCount]);;
}

- (void) windowDidResignMain: (NSNotification*)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:GameDidResignMainNotification
														object:[_board go]];
	[[NSNotificationCenter defaultCenter] postNotificationName:GoDocumentDidResignMainNotification
														object:self];
}

- (void) turnBegin:(NSNotification *)notification
{
	Go *go = [notification object];
	PlayerColorType turn = [go turn];
	if ([_players[turn] playGo:go
				  forColorType:turn] == NO)

	{
		NSLog(@"board on");
		[_board setEditable:YES];
	}
}

- (void) playerShouldPutStoneAtLocation:(GoLocation)location
{
	Go *go = [_board go];
	PlayerColorType turn = [go turn];

		NSLog(@"board off");
	[_board setEditable:NO];
	[_players[turn] playGo:go
	  withStoneOfColorType:turn
				atLocation:location];
}

- (void) dealloc
{
	RELEASE(_players[BlackPlayerType]);
	RELEASE(_players[WhitePlayerType]);
//	RELEASE(_board); // need fix in gnustep
	[super dealloc];
	NSLog(@"done degodoc");
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
	return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	return YES;
}

- (void) setPlayer:(Player *)player
	  forColorType:(PlayerColorType)color
{
	ASSIGN(_players[color], player);
}

@end
