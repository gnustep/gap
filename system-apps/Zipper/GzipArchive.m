#import <Foundation/Foundation.h>
#import "GzipArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"
#import "NSFileManager+Custom.h"

@interface GzipArchive (PrivateAPI)
@end

/**
 * This Archvie subclass handles plain gzipped files, i.e. not .tar.gz files. See TarArchive
 * for the handling of gzipped tar archives.
 */
@implementation GzipArchive : Archive

/**
 * register our supported file extensions with superclass.
 */
+ (void)initialize
{
	[self registerFileExtension:@"gz" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences gzipExecutable];
}

/**
 * Gzip files represent a single compressed file in this scope and thus can be decompressed
 * without path.
 */
+ (BOOL)canExtractWithoutFullPath
{
	return YES;
}

+ (ArchiveType)archiveType
{
	return GZIP;
}

//------------------------------------------------------------------------------
// expanding the archive
//------------------------------------------------------------------------------
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path
{
	NSArray *arguments;
	NSString *destPath;
	
	destPath = [path stringByAppendingPathComponent:[self path]];
	
	// make sure the full path underneath the temp dir exists
	[[NSFileManager defaultManager] createDirectoryPathWithParents:
		[destPath stringByDeletingLastPathComponent]];
	// make a copy of the file to extract it in the temp dir
	[[NSFileManager defaultManager] copyPath:[self path] toPath:destPath handler:nil];
	
	// extract it
	arguments = [NSArray arrayWithObjects:@"-d", destPath, @"--", nil];
	
	return [self runUnarchiverWithArguments:arguments];
}

- (NSArray *)listContents
{
	FileInfo *info;
	NSString *path;
	
	path = [[self path] stringByDeletingPathExtension];
	info = [FileInfo newWithPath:path date:nil size:nil];	
	return [NSArray arrayWithObject:info];
}

@end
