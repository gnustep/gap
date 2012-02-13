#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ArchiveService.h"
#import "TarArchive.h"

@interface ArchiveService (PrivateAPI)
- (void)createArchiveForFiles:(NSArray *)filenames;
@end

@implementation ArchiveService : NSObject

- (void)createZippedTarArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;
{
	NSArray *types;
	id filenames;
	
	types = [pboard types];
	if ([types containsObject:NSFilenamesPboardType] == NO)
	{
		*error = @"We expect Filenames on the pasteboard!";
		return;
	}
	
	filenames = [pboard propertyListForType:NSFilenamesPboardType];
	if (filenames == nil)
	{
		*error = @"could not read filename off the pasteboard!";
		return;
	}
	
	[self createArchiveForFiles:filenames];
}

- (void)createArchiveForFiles:(NSArray *)filenames;
{
	int rc;
	
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setTitle:@"Archive destination"];
	rc = [panel runModalForDirectory:NSHomeDirectory() file:nil];
	if (rc == NSOKButton)
	{
		NSString *archiveFile = [panel filename];
		// create the archive
		[TarArchive createArchive:archiveFile withFiles:filenames];
	}
}

@end
