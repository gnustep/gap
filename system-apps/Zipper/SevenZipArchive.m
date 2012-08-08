#import <Foundation/Foundation.h>
#import "SevenZipArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"

@interface SevenZipArchive (PrivateAPI)
- (NSData *)dataByRunningSevenZip;
- (NSArray *)listSevenZipContents:(NSArray *)lines;
@end

@implementation SevenZipArchive : Archive

/**
 * register our supported file extensions with superclass.
 */
+ (void)initialize
{
	[self registerFileExtension:@"7z" forArchiveClass:self];
	[self registerFileExtension:@"7za" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences sevenZipExecutable];
}

+ (BOOL)hasRatio;
{
	return NO;
}

+ (NSString *)archiveType
{
	return @"7zip";
}

//------------------------------------------------------------------------------
// expanding the archive
//------------------------------------------------------------------------------
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path
{
	FileInfo *fileInfo;
	NSMutableArray *args;
		
	args = [NSMutableArray array];

	if (usePathInfo == YES)
	{
		[args addObject:@"x"];
	}
	else
	{
		// extract flat
		[args addObject:@"e"];
	}

	// assume yes on all queries (needed for silently overwriting files)
	[args addObject:@"-y"];

	// destination dir, path must not be separated with blank from the 'o' option
	[args addObject:[@"-o" stringByAppendingString:path]];

	// protect for archives and files starting with -
	[args addObject:@"--"];	

	// add archive filename	
	[args addObject:[self path]];	

	if (files != nil)
	{
		NSEnumerator *cursor = [files objectEnumerator];
		while ((fileInfo = [cursor nextObject]) != nil)
		{
			[args addObject:[fileInfo fullPath]];
		}
	}
	
	return [self runUnarchiverWithArguments:args];
}

- (NSArray *)listContents
{    
    NSData *data = [self dataByRunningSevenZip];
    NSString *string = [[[NSString alloc] initWithData:data 
		encoding:NSASCIIStringEncoding] autorelease];	
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    
    // take out first 8 lines (header) and last 2 lines (footer)
	lines = [lines subarrayWithRange:NSMakeRange(17, [lines count] - 17)];
	lines = [lines subarrayWithRange:NSMakeRange(0, [lines count] - 3)];
    
    return [self listSevenZipContents:lines];
}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (NSArray *)listSevenZipContents:(NSArray *)lines
{    
    NSEnumerator *cursor;
    NSString *line;
	NSMutableArray *results = [NSMutableArray array];
	    
    cursor = [lines objectEnumerator];
    while ((line = [cursor nextObject]) != nil)
    {
        int length;
        NSString *path, *date, *time, *attributes;
        NSCalendarDate *calendarDate;
        FileInfo *info;
        NSArray *components;

		if ([line length] == 0)
		{
			continue;
		}
		
		components = [line componentsSeparatedByString:@" "];
		components = [components arrayByRemovingEmptyStrings];
		
		// directly skip directory entries. Fortunately, 7zip displays attributes for each file
		attributes = [components objectAtIndex:2];
		if ([attributes characterAtIndex:0] == 'D')
		{
			continue;
		}

		length = [[components objectAtIndex:3] intValue];

		// extract the path, it's always the last element
		path = [[components lastObject] stringByRemovingWhitespaceFromBeginning];
		
		date = [components objectAtIndex:0];
		time = [components objectAtIndex:1];		
        date = [NSString stringWithFormat:@"%@ %@", date, time];
        calendarDate = [NSCalendarDate dateWithString:date calendarFormat:@"%Y-%m-%d %H:%M:%S"];

		info = [FileInfo newWithPath:path date:calendarDate 
			size:[NSNumber numberWithInt:length]];
        [results addObject:info];
    }
    return results;
}

- (NSData *)dataByRunningSevenZip
{
	// l = list
	NSArray *args = [NSArray arrayWithObjects:@"l", @"--", [self path], nil];
	return [self dataByRunningUnachiverWithArguments:args];
}

@end
