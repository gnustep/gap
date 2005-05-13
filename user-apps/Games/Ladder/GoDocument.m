#include "GoDocument.h"

@implementation GoDocument

- (id) init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:GameDidBecomeMainNotification
														object:[_board go]];
	NSLog(@"%@ %d", [_board go],[[_board go] retainCount]);;
}

- (void) windowDidResignMain: (NSNotification*)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:GameDidResignMainNotification
														object:[_board go]];
}

/*
- (void) playerShouldPutStoneAtLocation:(GoLocation)location
{
}
*/

- (void) dealloc
{
	NSLog(@"dealloc GoDocument %@ %d",self,[_board retainCount]);
//	RELEASE(_board);
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

@end
