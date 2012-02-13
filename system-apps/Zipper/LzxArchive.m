#import <Foundation/Foundation.h>
#import "LzxArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"

@interface LzxArchive (PrivateAPI)
- (NSData *)dataByRunningLzx;
@end

@implementation LzxArchive : Archive

/**
 * register our supported file extensions with our superclass.
 */
+ (void)initialize
{
	[self registerFileExtension:@"lzx" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences lzxExecutable];
}

/**
 * lzx archives can only be unpacked with path info
 */
+ (BOOL)canExtractWithoutFullPath
{
	return NO;
}

/**
 * lzx archives <em>do not</em> contain info about compression ratio.
 */
+ (BOOL)hasRatio;
{
	return NO;
}

+ (NSString *)archiveType
{
	return @"LZX";	
}

//------------------------------------------------------------------------------
// expanding the archive
//------------------------------------------------------------------------------
/**
 * the unlzx command does not allow to unpack single files from the archive. We 
 * resort to unpacking the entire archive instead ...
 */
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path
{
	NSArray *args;
		
	args = [NSArray arrayWithObjects:@"-x", [self path], nil];
	return [[self class] runUnarchiverWithArguments:args inDirectory:path];
}

- (NSArray *)listContents
{
	NSEnumerator *cursor;
	NSString *line;
    
    NSMutableArray *results = [NSMutableArray array];
    NSData *data = [self dataByRunningLzx];
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
		NSString *path, *dateString, *timeString;
		NSCalendarDate *date;
		FileInfo *info;
		
		components = [line componentsSeparatedByString:@" "];
		components = [components arrayByRemovingEmptyStrings];

		timeString = [components objectAtIndex:2];
		if ([timeString isEqual:@"Merged"])
		{
			// skip lines that continue "Merged" in the time column, they contain no usable info
			continue;
		}
		
		length = [[components objectAtIndex:0] intValue];
		path = [components objectAtIndex:5];
		if ([path hasPrefix:@"\""])
		{
			path = [path substringFromIndex:1];
		}
		if ([path hasSuffix:@"\""])
		{
			path = [path substringToIndex:[path length] - 1];
		}	
		
		dateString = [components objectAtIndex:3];		
		dateString = [NSString stringWithFormat:@"%@ %@", dateString, timeString];
		date = [NSCalendarDate dateWithString:dateString calendarFormat:@"%d-%b-%Y %H:%M:%S"];
		
		info = [FileInfo newWithPath:path date:date size:[NSNumber numberWithInt:length]];
		[results addObject:info];
	}	 

    return results;
}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (NSData *)dataByRunningLzx
{
	NSData *data;
	
	NSArray *args = [NSArray arrayWithObjects:@"-v", [self path], nil];
	data = [self dataByRunningUnachiverWithArguments:args];
	return data;
}

@end
