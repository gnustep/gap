/*
   Project: StepSync
   FileMap.m

   Copyright (C) 2017 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2017-02-03

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "FileMap.h"
#import "FileObject.h"

@implementation FileMap

- (id) init
{
  if ((self = [super init]))
    {
      rootPath = nil;
      directories = [NSMutableArray new];
      files = [NSMutableArray new];
      fm = [NSFileManager defaultManager];
    }
  return self;
}

- (void) dealloc
{
  [rootPath release];
  [directories release];
  [files release];
  [super dealloc];
}

- (void)setRootPath:(NSString *)path
{
  if (rootPath != path)
    {
      [rootPath release];
      rootPath = path;
      [rootPath retain];
    }
}

- (NSMutableArray *)directories
{
  return directories;
}

- (NSMutableArray *)files
{
  return files;
}

- (void)analyzeRecursePath:(NSString *)path currentDepth:(unsigned)depth
{
  NSArray *dirContents;
  NSUInteger i;
  NSDictionary *attr;
  
  dirContents = [fm directoryContentsAtPath:path];
  for (i = 0; i < [dirContents count]; i++)
    {
      NSString *element;
      NSString *fullPath;
      BOOL isDir;
      NSDictionary *attr;
      NSString *fileType;
      
      element = [dirContents objectAtIndex:i];
      fullPath = [path stringByAppendingPathComponent:element];
      //NSLog(@"element: %@", element);
      attr = [fm fileAttributesAtPath:fullPath traverseLink:NO];
      fileType = [attr fileType];
      NSLog(@"fileType: %@", fileType);
      if (fileType == NSFileTypeDirectory)
        {
          [directories addObject:element];
          if (depth > 0)
            [self analyzeRecursePath:fullPath currentDepth:depth-1];
          else
            NSLog(@"Max recurse depth reached in %@", path);
        }
      else if (fileType == NSFileTypeRegular)
        {
          FileObject *fo;
          NSString *relPath;
          
          relPath = [fullPath substringFromIndex:[rootPath length]+1];
          NSLog(@"relPath: %@", relPath);
          fo = [[FileObject alloc] init];
          [fo setAbsolutePath:fullPath];
          [fo setRelativePath:relPath];
          [fo setFileAttributes:attr];
          [files addObject: fo];
          [fo release];
        }
      else if (fileType == NSFileTypeSymbolicLink)
        {
          NSLog(@"%@ link not handled", element);
        }
      else
        {
          NSLog(@"unknown not handled file type");
        }
    }
}

- (void)analyze
{
  BOOL isDir;
  
  if (nil == rootPath)
    return;
  
  /* check if root is dir and exists */
  if (!([fm fileExistsAtPath:rootPath isDirectory:&isDir] && isDir))
    {
      NSLog(@"Root path is not a directory or does not exist: %@", rootPath);
      return;
    }
  [self analyzeRecursePath:rootPath currentDepth:1024];
}

@end
