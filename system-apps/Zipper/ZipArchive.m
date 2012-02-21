/*

  ZipArchive.m
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>

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
#import "ZipArchive.h"
#import "FileInfo.h"
#import "NSString+Custom.h"
#import "Preferences.h"
#import "NSArray+Custom.h"

// if the output contains this string in the first line, we have to use a different
// parsing routine
#define MINI_UNZIP_IDENTIFIER @"MiniUnz"

static NSData *_magicBytes = nil;

@interface ZipArchive (PrivateAPI)
- (NSData *)dataByRunningUnzip;
- (NSArray *)listUnzipContents:(NSArray *)lines;
@end

@implementation ZipArchive : Archive

/**
 * register our supported file extensions with superclass.
 */
+ (void)initialize
{
	// zip files start with 'P K 0x003 0x004'
	char zipBytes[] = { 'P', 'K', 0x003, 0x004 };
	_magicBytes = [[NSData dataWithBytes:zipBytes length:4] retain];
	
	[self registerFileExtension:@"zip" forArchiveClass:self];
	[self registerFileExtension:@"jar" forArchiveClass:self];
}

+ (NSString *)unarchiveExecutable
{
	return [Preferences zipExecutable];
}

+ (BOOL)hasRatio;
{
	// unzip does provide info about the compression ratio
	return YES;
}

+ (NSString *)archiveType
{
	return @"Zip";
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
	[args addObject:@"-qq"];
	// overwrite without warning
	[args addObject:@"-o"];
	if (usePathInfo == NO)
	{
		// junk paths
		[args addObject:@"-j"];
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
	
	// destination dir
	[args addObject:@"-d"];
	[args addObject:path];
	
	return [self runUnarchiverWithArguments:args];
}

- (NSArray *)listContents
{    
    NSData *data = [self dataByRunningUnzip];
    NSString *string = [[[NSString alloc] initWithData:data  
        encoding:NSASCIIStringEncoding] autorelease];	
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    
    if ([[lines objectAtIndex:0] containsString:MINI_UNZIP_IDENTIFIER])
    {
		// take out the first 6 lines (header)
		lines = [lines subarrayWithRange:NSMakeRange(6, [lines count] - 6)];
    }
    
    return [self listUnzipContents:lines];
}

- (NSArray *)listUnzipContents:(NSArray *)lines
{    
  NSEnumerator *cursor;
  NSString *line;
  NSMutableArray *results = [NSMutableArray array];
	    
  cursor = [lines objectEnumerator];
  while ((line = [cursor nextObject]) != nil)
    {
      int length, index;
      NSString *path, *date, *time, *ratio, *checksum;
      NSCalendarDate *calendarDate;
      NSArray *components;

      if (line == nil || [line length] == 0)
	continue;

      components = [line componentsSeparatedByString:@" "];
      components = [components arrayByRemovingEmptyStrings];

      length = [[components objectAtIndex:0] intValue];
      ratio = [components objectAtIndex:3];

      // extract the path. The checksum is the last token before the full path 
      // (which can contain blanks) 
      checksum = [components objectAtIndex:6];
      index = [line rangeOfString:checksum].location;
      index += [checksum length];
      path = [[line substringFromIndex:index] stringByRemovingWhitespaceFromBeginning];
		
      date = [components objectAtIndex:4];
      time = [components objectAtIndex:5];		
      date = [NSString stringWithFormat:@"%@ %@", date, time];
      calendarDate = [NSCalendarDate dateWithString:date calendarFormat:@"%m-%d-%Y %H:%M"];

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
// private API
//------------------------------------------------------------------------------
- (NSData *)dataByRunningUnzip
{
	// l = list
	// v = display all zip infos (Ratio etc.)
	// qq = quiet, this is important for skipping comments in archives and for skipping
	//      the nice headers for readable output
	NSArray *args = [NSArray arrayWithObjects:@"-lvqq", [self path], nil];
	return [self dataByRunningUnachiverWithArguments:args];
}

@end
