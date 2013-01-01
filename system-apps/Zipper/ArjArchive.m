#import <Foundation/Foundation.h>
#import "ArjArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"
#import "common.h"

static NSData *_magicBytes;

@interface ArjArchive (PrivateAPI)
- (NSData *)dataByRunningArj;
@end

@implementation ArjArchive : Archive

/**
 * register our supported file extensions with our superclass.
 */
+ (void)initialize
{
	// arj starts with 0xea60
	char rarBytes[] = { 0xea, 0x60 };
	_magicBytes = [[NSData dataWithBytes:rarBytes length:2] retain];
	
	[self registerFileExtension:@"arj" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences unarjExecutable];
}

/**
 * arj archives <em>do</em> contain info about compression ratio.
 */
+ (BOOL)hasRatio;
{
	return YES;
}

+ (ArchiveType)archiveType
{
	return ARJ;
}

+ (NSData *)magicBytes
{
	return _magicBytes;
}

//------------------------------------------------------------------------------
// expanding the archive
//------------------------------------------------------------------------------
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path
{
	FileInfo *fileInfo;
	NSMutableArray *args;
	
	args = [NSMutableArray array];
	[args addObject:@"x"];

	[args addObject:[self path]];
	
	// this doesn't work with unarj, either extract
	// whole archive, or nothing
	/* if (files != nil)
	{
		NSEnumerator *cursor = [files objectEnumerator];
		while ((fileInfo = [cursor nextObject]) != nil)
		{
			[args addObject:[fileInfo fullPath]];
		}
	} */
	
	// there is no parameter allowing to specify destination dir
	return [self runUnarchiverWithArguments:args inDirectory:path];
}

- (NSArray *)listContents
{
	NSUInteger lineCount, i;
	NSString *path = nil;
    
    NSMutableArray *results = [NSMutableArray array];
    NSData *data = [self dataByRunningArj];
    NSString *string = [[[NSString alloc] initWithData:data 
		encoding:NSASCIIStringEncoding] autorelease];
    NSArray *lines = [string componentsSeparatedByString:@"\n"];

    // take out first 7 lines (header) and last 2 lines (footer)
    lines = [lines subarrayWithRange:NSMakeRange(6, [lines count] - 6)];
    lines = [lines subarrayWithRange:NSMakeRange(0, [lines count] - 3)];

	lineCount = [lines count];
	for (i = 0; i < lineCount; i++)
	  {
            NSString *line = nil;
	    NSArray *components;
	    NSString *date, *ratio;
	    int length;
	    NSCalendarDate *calendarDate;
	    FileInfo *info;

	    line = [lines objectAtIndex:i];
	    components = [[line componentsSeparatedByString:@" "] arrayByRemovingEmptyStrings];
	    path = [components objectAtIndex:0];
	    length = [[components objectAtIndex:1] intValue];
	    ratio = [components objectAtIndex:3];

	    date = [components objectAtIndex:4];
	    date = [NSString stringWithFormat:@"%@ %@", date, [components objectAtIndex:5]];
        		calendarDate = [NSCalendarDate dateWithString:date 
					calendarFormat:@"%d-%m-%y %H:%M:%S"];

			info = [FileInfo newWithPath:path date:calendarDate 
				size:[NSNumber numberWithInt:length] ratio:ratio];
	        	[results addObject:info];
	}
    return results;
}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (NSData *)dataByRunningArj
{
	// Args for unarj:
	// l	view contents of archive

	NSArray *args = [NSArray arrayWithObjects:@"l", [self path], nil];
	return [self dataByRunningUnachiverWithArguments:args];
}

@end
