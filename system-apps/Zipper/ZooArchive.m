/*

  ZooArchive.m
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

  Authors: Sebastian Reitenbach <sebastia@l00-bugdead-prods.de>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#include <unistd.h>
#import <Foundation/Foundation.h>
#import "ZooArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"

static NSData *_magicBytes = nil;

@interface ZooArchive (PrivateAPI)
- (NSData *)dataByRunningZoo;
- (NSArray *)listZooContents:(NSArray *)lines;
@end

@implementation ZooArchive : Archive

/**
 * register our supported file extensions with superclass.
 */
+ (void)initialize
{
	// zoo files start with 0xfdc4a7dc
	char zooBytes[] = { 0xfd, 0xc4, 0xa7, 0xdc };
	_magicBytes = [[NSData dataWithBytes:zooBytes length:4] retain];

	[self registerFileExtension:@"zoo" forArchiveClass:self];
}

+ (NSString *)archiveExecutable
{
	return [Preferences zooExecutable];
}
+ (NSString *)unarchiveExecutable
{
	return [Preferences zooExecutable];
}


+ (BOOL)hasRatio;
{
	// unzip does provide info about the compression ratio
	return YES;
}

+ (ArchiveType)archiveType
{
	return ZOO;
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
	// be really quiet
	if (usePathInfo == YES)
	  {
	    // overwrite without warning
	    [args addObject:@"x.OOqqq"];
	  }
	else
	  {
	    // junk paths
	    [args addObject:@"x:OOqqq"];
	  }
	[args addObject:[self path]];	
	
	if (files != nil)
	{
		NSEnumerator *cursor = [files objectEnumerator];
		while ((fileInfo = [cursor nextObject]) != nil)
		{
			[args addObject:[fileInfo fullPath]];
		}
	}

	// zoo doesn't seem to support a parameter to specify
	// a directory where it should be extracted, so change working
	// directory to the destination
	chdir([path UTF8String]); 
	return [self runUnarchiverWithArguments:args];
}

- (NSArray *)listContents
{    
    NSData *data = [self dataByRunningZoo];
    NSString *string = [[[NSString alloc] initWithData:data  
        encoding:NSASCIIStringEncoding] autorelease];	
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    return [self listZooContents:lines];
}

- (NSArray *)listZooContents:(NSArray *)lines
{    
  NSEnumerator *cursor;
  NSString *line;
  NSMutableArray *results = [NSMutableArray array];
	    
  cursor = [lines objectEnumerator];
  while ((line = [cursor nextObject]) != nil)
    {
      int length, index;
      NSString *path, *date, *ratio, *checksum;
      NSCalendarDate *calendarDate;
      NSArray *components;

      if (line == nil || [line length] == 0)
	continue;

      components = [line componentsSeparatedByString:@" "];
      components = [components arrayByRemovingEmptyStrings];

      length = [[components objectAtIndex:0] intValue];
      ratio = [components objectAtIndex:1];

      // extract the path. The checksum is the last token before the full path 
      // (which can contain blanks) 
      checksum = [components objectAtIndex:6];
      index = [line rangeOfString:checksum].location;
      index += [checksum length];
      path = [[line substringFromIndex:index] stringByRemovingWhitespaceFromBeginning];
		
      date = [NSString stringWithFormat:@"%@ %@ %@ %@", 
		[components objectAtIndex:3], 
		[components objectAtIndex:4], 
		[components objectAtIndex:5], 
		[components objectAtIndex:6]];
      calendarDate = [NSCalendarDate dateWithString:date calendarFormat:@"%d %b %y %H:%M:%S"];
      // we skip plain directory entries
      if ([path hasSuffix:@"/"] == NO)
	{
	  FileInfo *info;

	  info = [FileInfo newWithPath:path date:calendarDate 
				  size:[NSNumber numberWithInt:length] ratio:ratio];
	  if (info)
	    [results addObject:info];
	  [info release];
	} 
    }
  return results;
}

//------------------------------------------------------------------------------
// creating archives
//------------------------------------------------------------------------------
// this method should probably be split into separate methods
+ (void)createArchive:(NSString *)archivePath withFiles:(NSArray *)filenames archiveType: (ArchiveType) archiveType
{
        NSEnumerator *filenameCursor;
        NSString *filename;
        NSString *workdir;
        NSMutableArray *arguments;
	NSPipe *pipe;
	NSData *inData;
	NSFileHandle *readHandle;
	NSTask *task;
	NSMutableData *result;
	NSString *string;
	NSArray *files;

        // make sure archivePath has the correct suffix
        if ([archivePath hasSuffix:@".zoo"] == NO)
          {
            archivePath = [archivePath stringByAppendingString:@".zoo"];
          }
        // build arguments for commandline: zoo aqqq filename <list of files>

	// zoo doesn't recursively add directories to the archive, so we have to
	// create a list of files on our own
        // change into this directory before searching for the files
        workdir = [[filenames objectAtIndex:0] stringByDeletingLastPathComponent];
	chdir([workdir UTF8String]);
	// We use find to find all files below the potential directories
	// should work at least on Linux/*BSD/ type of systems
        arguments = [NSMutableArray array];
        // filenames contains absolute paths, convert them to relative paths. This works
        // because you can select only files/directories below a current directory in
        // GWorkspace so all the files *have* to have a common filesystem root.
        filenameCursor = [filenames objectEnumerator];
        while ((filename = [filenameCursor nextObject]) != nil)
          {
            [arguments addObject:[filename lastPathComponent]];
          }
	[arguments addObject:@"-type"];
	[arguments addObject:@"f"];
    	pipe = [NSPipe pipe];
    	readHandle = [pipe fileHandleForReading];
	task = [[NSTask alloc] init];
	[task setLaunchPath:@"find"];
	[task setArguments:arguments];
	[task setStandardOutput:pipe];
	[task launch];

	result = [NSMutableData dataWithCapacity:1024];
	while ((inData = [readHandle availableData]) && [inData length])
	  {
	    [result appendData:inData];
	  }
        string = [[[NSString alloc] initWithData:result
                encoding:NSASCIIStringEncoding] autorelease];
        files = [string componentsSeparatedByString:@"\n"];
	[task release];

        // build arguments for commandline: zoo aqqq filename <list of files>
	// do the arguments need to be released before reusing them?
        arguments = [NSMutableArray array];
	[arguments addObject:@"aqqq"];
        [arguments addObject:archivePath];
	filenameCursor = [files objectEnumerator];
	while ((filename = [filenameCursor nextObject]) != nil)
          {
            [arguments addObject:filename];
          }
	
        [self runArchiverWithArguments:arguments inDirectory:workdir];
}

//------------------------------------------------------------------------------
// private API
//------------------------------------------------------------------------------
- (NSData *)dataByRunningZoo
{
	// l = list
	// q = quiet, this is important for skipping comments in archives and for skipping
	//      the nice headers for readable output
	NSArray *args = [NSArray arrayWithObjects:@"lq", [self path], nil];
	return [self dataByRunningUnachiverWithArguments:args];
}

@end
