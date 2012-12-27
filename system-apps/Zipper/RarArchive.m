#import <Foundation/Foundation.h>
#import "RarArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"
#import "common.h"

static NSData *_magicBytes;

@interface RarArchive (PrivateAPI)
- (NSData *)dataByRunningRar;
@end

@implementation RarArchive : Archive

/**
 * register our supported file extensions with our superclass.
 */
+ (void)initialize
{
	// rar files start with 'R a r !'
	char rarBytes[] = { 'R', 'a', 'r', '!' };
	_magicBytes = [[NSData dataWithBytes:rarBytes length:4] retain];
	
	[self registerFileExtension:@"rar" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences rarExecutable];
}

/**
 * rar archives <em>do</em> contain info about compression ratio.
 */
+ (BOOL)hasRatio;
{
	return YES;
}

+ (ArchiveType)archiveType
{
	return RAR;
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
	if (usePathInfo)
	{
		[args addObject:@"x"];
	}
	else
	{
		[args addObject:@"e"];
	}

	// protect against archives and files starting with -
	[args addObject:@"--"];

	[args addObject:[self path]];
	
	if (files != nil)
	{
		NSEnumerator *cursor = [files objectEnumerator];
		while ((fileInfo = [cursor nextObject]) != nil)
		{
			[args addObject:[fileInfo fullPath]];
		}
	}
	
	// destination dir
	[args addObject:path];
	return [self runUnarchiverWithArguments:args];
}

- (NSArray *)listContents
{
	int lineCount, i;
	NSString *path = nil;
    
    NSMutableArray *results = [NSMutableArray array];
    NSData *data = [self dataByRunningRar];
    NSString *string = [[[NSString alloc] initWithData:data 
		encoding:NSASCIIStringEncoding] autorelease];
    NSArray *lines = [string componentsSeparatedByString:@"\n"];

    // take out first 9 lines (header) and last 3 lines (footer)
    lines = [lines subarrayWithRange:NSMakeRange(8, [lines count] - 8)];
    lines = [lines subarrayWithRange:NSMakeRange(0, [lines count] - 4)];

	lineCount = [lines count];
	for (i = 0; i < lineCount; i++)
	{
        NSString *line = nil;
	
		line = [lines objectAtIndex:i];
		if ((i % 2) == 0)
		{
			path = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		else
		{
			NSArray *components;
			NSString *date, *ratio;
	        int length;
			NSCalendarDate *calendarDate;
			FileInfo *info;
			
			components = [[line componentsSeparatedByString:@" "] arrayByRemovingEmptyStrings];
			// continue only for non-directory entries
			if ([[components objectAtIndex:5] hasPrefix:@"d"] == NO)
			{
				length = [[components objectAtIndex:0] intValue];
				ratio = [components objectAtIndex:2];

				date = [components objectAtIndex:3];
				date = [NSString stringWithFormat:@"%@ %@", date, [components objectAtIndex:4]];
        		calendarDate = [NSCalendarDate dateWithString:date 
					calendarFormat:@"%d-%m-%y %H:%M"];

				info = [FileInfo newWithPath:path date:calendarDate 
					size:[NSNumber numberWithInt:length] ratio:ratio];
	        	[results addObject:info];
			}
		}
	}
    return results;
}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (NSData *)dataByRunningRar
{
	// Args for rar:
	// v	view contents of archive
	// -c-	suppress archive comment

	NSArray *args = [NSArray arrayWithObjects:@"v", @"-c-", @"--", [self path], nil];
	return [self dataByRunningUnachiverWithArguments:args];
}

@end
