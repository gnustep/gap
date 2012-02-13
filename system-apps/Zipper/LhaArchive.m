#import <Foundation/Foundation.h>
#import "LhaArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"

@interface LhaArchive (PrivateAPI)
- (NSData *)dataByRunningLha;
@end

@implementation LhaArchive : Archive

/**
 * register our supported file extensions with our superclass.
 */
+ (void)initialize
{
	[self registerFileExtension:@"lha" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences lhaExecutable];
}

/**
 * lha archives <em>do</em> contain info about compression ratio.
 */
+ (BOOL)hasRatio;
{
	return YES;
}

+ (NSString *)archiveType
{
	return @"LHA";	
}

//------------------------------------------------------------------------------
// expanding the archive
//------------------------------------------------------------------------------
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path
{
	FileInfo *fileInfo;
	NSMutableArray *args;
	NSString *argString;
	
	argString = @"e";
	if (usePathInfo == NO)
	{
		argString = [argString stringByAppendingString:@"i"];
	}
	// destination dir
	argString = [argString stringByAppendingString:@"w="];
	argString = [argString stringByAppendingString:path];

	args = [NSMutableArray array];
	[args addObject:argString];
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
	NSEnumerator *cursor;
	NSString *line;
    
    NSMutableArray *results = [NSMutableArray array];
    NSData *data = [self dataByRunningLha];
    NSString *string = [[[NSString alloc] initWithData:data 
		encoding:NSASCIIStringEncoding] autorelease];
    NSArray *lines = [string componentsSeparatedByString:@"\n"];

    // take out first 2 lines (header) and last 2 lines (footer)
    lines = [lines subarrayWithRange:NSMakeRange(2, [lines count] - 2)];
    lines = [lines subarrayWithRange:NSMakeRange(0, [lines count] - 3)];

	cursor = [lines objectEnumerator];
	while ((line = [cursor nextObject]) != nil)
	{
		NSArray *components;
		int length;
		NSString *path, *ratio, *month, *day, *year, *dateString;
		NSCalendarDate *date;
		FileInfo *info;
		
		if ([line hasSuffix:@"/"])
		{
			// skip directory entries
			continue;
		}
		
		components = [line componentsSeparatedByString:@" "];
		components = [components arrayByRemovingEmptyStrings];
		
		length = [[components objectAtIndex:3] intValue];
		path = [components objectAtIndex:10];
		ratio = [components objectAtIndex:4];
		
		month = [components objectAtIndex:7];
		day = [components objectAtIndex:8];
		year = [components objectAtIndex:9];
		dateString = [NSString stringWithFormat:@"%@ %@ %@", month, day, year];
		date = [NSCalendarDate dateWithString:dateString calendarFormat:@"%b %d %Y"];
		
		info = [FileInfo newWithPath:path date:date size:[NSNumber numberWithInt:length]
			ratio:ratio];
		[results addObject:info];
	}	 

    return results;
}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (NSData *)dataByRunningLha
{
	NSData *data;
	NSArray *args = [NSArray arrayWithObjects:@"v", [self path], nil];
	data = [self dataByRunningUnachiverWithArguments:args];
	NSLog(@"dataByRunningLha: %@", data);
	return data;
}

@end
