#import <Foundation/Foundation.h>
#import "TarArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"

@interface TarArchive (PrivateAPI)
- (NSData *)dataByRunningTar;
- (FileInfo *)fileInfoFromLine:(NSString *)line;
@end

@implementation TarArchive : Archive

/**
 * register our supported file extensions with superclass.
 */
+ (void)initialize
{
	[self registerFileExtension:@"tar" forArchiveClass:self];
	[self registerFileExtension:@"tar.gz" forArchiveClass:self];
	[self registerFileExtension:@"tgz" forArchiveClass:self];
	[self registerFileExtension:@"tar.bz2" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences tarExecutable];
}

/**
 * Tar files inherently have the full path info and can't be uncompressed flat.
 */
+ (BOOL)canExtractWithoutFullPath
{
	return NO;
}

+ (NSString *)archiveType
{
	return @"tar";
}

//------------------------------------------------------------------------------
// expanding the archive
//------------------------------------------------------------------------------
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path
{
	FileInfo *fileInfo;
	NSString *compressionArg;
	NSMutableArray *args;
	
	compressionArg = [Preferences compressionArgumentForFile:[self path]];
	NSParameterAssert(compressionArg != nil);

	args = [NSMutableArray array];
	[args addObject:@"-x"];
	// compression method
	[args addObject:compressionArg];
	// destination dir
	[args addObject:@"-C"];
	[args addObject:path];
	// the archive
	[args addObject:@"-f"];
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
    NSString *line;

    NSMutableArray *results = [NSMutableArray array];
    NSData *data = [self dataByRunningTar];
    NSString *string = [[[NSString alloc] initWithData:data 
		encoding:NSASCIIStringEncoding] autorelease];
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    
    NSEnumerator *cursor = [lines objectEnumerator];
    while ((line = [cursor nextObject]) != nil)
    {
		FileInfo *info;
		
		// BSD tar seems to add linefeed at the end of the line. strip that
		if ([line hasSuffix:@"\r"])
		{
			line = [line substringToIndex:[line length] - 1];
		}

		// we skip empty lines and plain directory entries
		if (([line length] == 0) || [line hasSuffix:@"/"])
		{
			continue;
		}
		
		info = [self fileInfoFromLine:line];
		if (info)
		  [results addObject:info];
	}
	return results;
}

//------------------------------------------------------------------------------
// creating archives
//------------------------------------------------------------------------------
+ (void)createArchive:(NSString *)archivePath withFiles:(NSArray *)filenames
{
	NSEnumerator *filenameCursor;
	NSString *filename;
	NSString *workdir;
	NSMutableArray *arguments;
	
	// make sure archivePath has the correct suffix
	if ([archivePath hasSuffix:@".tar.gz"] == NO)
	{
		archivePath = [archivePath stringByAppendingString:@".tar.gz"];
	}
	
	// build arguments for commandline: tar -czf filename <list of files>
	arguments = [NSMutableArray array];
	[arguments addObject:@"-czf"];
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

	// create the archive. In the case of TarArchive the unarchiver can also create
	// archives
	[self runUnarchiverWithArguments:arguments inDirectory:workdir];
}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (NSData *)dataByRunningTar
{
	NSString *compressionArg;
	NSMutableArray *arguments;
	
	compressionArg = [Preferences compressionArgumentForFile:[self path]];
	NSParameterAssert(compressionArg != nil);
	
	arguments = [NSMutableArray arrayWithObject:@"-tv"]; 
	if ([compressionArg isEqual:@""] == NO)
	{
		[arguments addObject:compressionArg];
	}
	[arguments addObject:@"-f"];
	[arguments addObject:[self path]];
	
	return [self dataByRunningUnachiverWithArguments:arguments];
}

- (FileInfo *)fileInfoFromLine:(NSString *)line
{
  int index, length = -1;
  NSString *path = nil;
  NSString *dateString = nil;
  NSString *time = nil;
  NSCalendarDate *calendarDate = nil;
  NSArray *components;
  FileInfo *fileInfo = nil;

  if (line == nil || [line length] == 0)
    return nil;
  if ([line hasPrefix:@"tar: "])
    return nil;
  components = [line componentsSeparatedByString:@" "];
  components = [components arrayByRemovingEmptyStrings];

  if ([Preferences isBsdTar])
    {
      NSArray *dateComponents;

      // BSD tar
      length = [[components objectAtIndex:4] intValue];

      dateComponents = [components subarrayWithRange:NSMakeRange(5, 3)];
      dateString = [dateComponents componentsJoinedByString:@" "];
      if ([dateString rangeOfString:@":"].location != NSNotFound)
	calendarDate = [NSCalendarDate dateWithString:dateString calendarFormat:@"%b %d %H:%M"];
      else
	calendarDate = [NSCalendarDate dateWithString:dateString calendarFormat:@"%b %d %Y"];
      index = [line rangeOfString:[components objectAtIndex:7]].location;
      index += [[components objectAtIndex:7] length];
    }
  else	
    {
      // linux tar
      NSString *date;
      
      length = [[components objectAtIndex:2] intValue];
      
      date = [components objectAtIndex:3];
      time = [components objectAtIndex:4];
      dateString = [NSString stringWithFormat:@"%@ %@", date, time];
      calendarDate = [NSCalendarDate dateWithString:dateString calendarFormat:@"%Y-%m-%d %H:%M"];
      if (calendarDate == nil)
	calendarDate = [NSCalendarDate dateWithString:dateString calendarFormat:@"%Y-%m-%d %H:%M:%S"];
      index = [line rangeOfString:dateString].location;
      index += [dateString length];
    }

  // The path is everything after the date string. Since it can contain blanks,
  // do *not* just grab any objects from components array
  if (index > 0)
    {
      path = [[line substringFromIndex:index] stringByRemovingWhitespaceFromBeginning];
      fileInfo = [FileInfo newWithPath:path date:calendarDate size:[NSNumber numberWithInt:length]];
    }

  return fileInfo;
}

@end
