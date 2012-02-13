#import <Foundation/Foundation.h>
#import "NSFileManager+Custom.h"

@implementation NSFileManager (Custom)

/**
 * Scans the <code>PATH</code> environment variable for aFilename and
 * returns the full path, or nil if aFilename cannot be found.
 */
- (NSString *)locateExecutable:(NSString *)aFilename;
{
	NSString *fullPath = nil;
	NSDictionary *environment = nil;
    NSString *path = nil;
    NSScanner *pathScanner;
    BOOL found = NO;
    
    environment = [[NSProcessInfo processInfo] environment];
    path = [environment objectForKey:@"PATH"];
    
    pathScanner = [NSScanner scannerWithString:path];
    
    while (([pathScanner isAtEnd] == NO) && (found == NO))
    {
		NSString *directory = nil;
		BOOL isScanned;
      
		isScanned = [pathScanner scanUpToString:@":" intoString:&directory];
		[pathScanner scanString:@":" intoString:NULL];
		fullPath = [directory stringByAppendingPathComponent:aFilename];
		found = [self fileExistsAtPath:fullPath];
    }
    
    if (found == NO)
	{
		fullPath = nil;
	}
	return fullPath;
}

/**
 * creates a temporary directory unique for Zipper.
 */
- (NSString *)createTemporaryDirectory;
{
	int attempt = 0;
	
	NSParameterAssert(NSTemporaryDirectory() != nil);
	// don't get caught in an endless loop. If we need more than 500 attempts 
	// to find a temp dir, something's wrong anyway
	while (attempt < 500)
	{
		NSString *tempDir;
		NSString *tempPath;
		
		tempDir = [NSString stringWithFormat:@"Zipper-%d", attempt++];
		tempPath = [NSString pathWithComponents:[NSArray arrayWithObjects:
			NSTemporaryDirectory(), tempDir, nil]];
		if ([self fileExistsAtPath:tempPath] == NO)
		{
			if ([self createDirectoryAtPath:tempPath attributes:nil])
			{
				return tempPath;
			}
		}		
	}
	
	[NSException raise:NSInvalidArgumentException format:@"Could not create temporary directory"];
	return nil;
}

- (void)createDirectoryPathWithParents:(NSString *)aPath
{
	NSString *parent;
	BOOL isDir;
		
	parent = [aPath stringByDeletingLastPathComponent];
	if (([self fileExistsAtPath:parent isDirectory:&isDir] && isDir) == NO)
	{
		// parent path does not exist, create it first
		[self createDirectoryPathWithParents:parent];
	}
	
	// parent exists, create directory
	[self createDirectoryAtPath:aPath attributes:nil];
}

@end
