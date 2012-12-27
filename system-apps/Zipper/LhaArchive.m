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

+ (NSString *)archiveExecutable
{
	return [Preferences lhaExecutable];
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

+ (ArchiveType)archiveType
{
	return LHA;	
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
// creating archives
//------------------------------------------------------------------------------
+ (void)createArchive:(NSString *)archivePath withFiles:(NSArray *)filenames archiveType: (ArchiveType) archiveType
{
        NSEnumerator *filenameCursor;
        NSString *filename;
        NSString *workdir;
        NSMutableArray *arguments;

        // make sure archivePath has the correct suffix
        if ([archivePath hasSuffix:@".lha"] == NO)
          {
            archivePath = [archivePath stringByAppendingString:@".lha"];
          }
        // build arguments for commandline: lha a filename <list of files>
        arguments = [NSMutableArray array];
        [arguments addObject:@"a"];
        [arguments addObject:archivePath];

        // filenames contains absolute paths, convert them to relative paths. This works
        // because you can select only files/directories below a current directory in
        // GWorkspace so all the files *have* to have a common filesystem root.
        filenameCursor = [filenames objectEnumerator];
        while ((filename = [filenameCursor nextObject]) != nil)
        {
                [arguments addObject:[filename lastPathComponent]];
        }

        // change into this directory when running the task
        workdir = [[filenames objectAtIndex:0] stringByDeletingLastPathComponent];

        [self runArchiverWithArguments:arguments inDirectory:workdir];
}


//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (NSData *)dataByRunningLha
{
	NSData *data;
	NSArray *args = [NSArray arrayWithObjects:@"v", @"--", [self path], nil];
	data = [self dataByRunningUnachiverWithArguments:args];
	return data;
}

@end
