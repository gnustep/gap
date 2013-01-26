/*

  TarArchive.m
  Zipper

  Copyright (C) 2012-2013 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>
           Sebastian Reitenbach <sebastia@l00-bugdead-prods.de>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
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
	[self registerFileExtension:@"tar.xz" forArchiveClass:self];
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

+ (ArchiveType)archiveType
{
	return TAR;
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

	if (compressionArg != nil && [compressionArg length] > 0)
	  {
	    // compression method
	    [args addObject:compressionArg];
	  }

	// the archive
	[args addObject:@"-f"];
	[args addObject:[self path]];

	// destination dir
	[args addObject:@"-C"];
	[args addObject:path];
	
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
  NSData *data;
  NSString *string;
  NSArray *lines;
  NSEnumerator *cursor;
  
  data = [self dataByRunningTar];
  string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  lines = [string componentsSeparatedByString:@"\n"];
  [string release];
  
  cursor = [lines objectEnumerator];
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
+ (void)createArchive:(NSString *)archivePath withFiles:(NSArray *)filenames archiveType: (ArchiveType) archiveType
{
	NSEnumerator *filenameCursor;
	NSString *filename;
	NSString *workdir;
	NSMutableArray *arguments;
	
	// make sure archivePath has the correct suffix
	// and build the command line arguments
	arguments = [NSMutableArray array];
	switch (archiveType)
	  {
	    case TAR:
	      if ([archivePath hasSuffix:@".tar"] == NO)
		{
		  archivePath = [archivePath stringByAppendingString:@".tar"];
		}
	      [arguments addObject:@"-cf"];
	      break;
	    case TARGZ:
	      if ([archivePath hasSuffix:@".tar.gz"] == NO)
		{
		  archivePath = [archivePath stringByAppendingString:@".tar.gz"];
		}
	      [arguments addObject:@"-czf"];
	      break;
	    case TARBZ2:
	      if ([archivePath hasSuffix:@".tar.bz2"] == NO)
	        {
	          archivePath = [archivePath stringByAppendingString:@".tar.bz2"];
		}
	      [arguments addObject:@"-cjf"];
	      break;
	    case TARXZ:
	      if ([Preferences isBsdTar])
		{
		  // this is at least true on OpenBSD
                  NSRunAlertPanel(@"Error", @"BSD tar doesn't support creation of tar.xz archives",
                                                @"OK", nil, nil, nil);
		  return;
		}
	      if ([archivePath hasSuffix:@".tar.xz"] == NO)
	        {
	          archivePath = [archivePath stringByAppendingString:@".tar.xz"];
		}
	      [arguments addObject:@"-cJf"];
	      break;
	    default:
              NSRunAlertPanel(@"Error", @"This type of tar archive is not supported for archive creation",
                                            @"OK", nil, nil, nil);
	      return;
	  }
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
