#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "AppDelegate.h"
#import "ZipArchive.h"
#import "TarArchive.h"
#import "RarArchive.h"
#import "LhaArchive.h"
#import "LzxArchive.h"
#import "GzipArchive.h"
#import "SevenZipArchive.h"
#import "PreferencesController.h"
#import "ArchiveService.h"

@implementation AppDelegate : NSObject

/**
 * load all Archive subclasses so that they can register their supported file extensions
 */
+ (void)initialize
{
	[LhaArchive class];
	[RarArchive class];
	[TarArchive class];
	[ZipArchive class];
	[LzxArchive class];
	[GzipArchive class];
	[SevenZipArchive class];
}

//------------------------------------------------------------------------------
// NSApp delegate methods
//------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)note
{	
	[NSApp setServicesProvider:[[ArchiveService alloc] init]];
}

/**
 * do cleanup, especially remove temporary files that were created while we ran
 */
-(void)applicationWillTerminate:(NSNotification *)aNotification
{
	NSEnumerator *cursor;
	NSString *element;
	
	// clean up all temporary Zipper directories
	cursor = [[[NSFileManager defaultManager] directoryContentsAtPath:NSTemporaryDirectory()]
		objectEnumerator];
	while ((element = [cursor nextObject]) != nil)
	{
		if ([element hasPrefix:@"Zipper"])
		{
			NSString *path;
			
			path = [NSString pathWithComponents:[NSArray arrayWithObjects:NSTemporaryDirectory(),
				element, nil]];
			[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
		}
	}
}

//------------------------------------------------------------------------------
// action methods
//------------------------------------------------------------------------------
- (void)showPreferences:(id)sender
{
	[[[PreferencesController alloc] init] showPreferencesPanel];
}
	
@end
