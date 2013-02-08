/* 
   Project: LaternaMagica
   FileTable.m

   Copyright (C) 2006-2013 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2006-01-16

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
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#include <math.h>

#import "FileTable.h"
#import "AppController.h"
#import "LMImage.h"

#ifdef __NetBSD__
#if __NetBSD_Version__ <= 299000000
#define lround (long)round
#endif
#endif

@implementation FileTable

- (id)init
{
  if ((self = [super init]))
    {
      filesToIgnore = [[NSArray arrayWithObjects:
                                @".DS_Store",
                                @".gwdir",
                                @"Thumbs.db",
                                nil] retain];
      images = [[NSMutableArray arrayWithCapacity:5] retain];
    }
  return self;
}

-(BOOL)addPathAndRecurse: (NSString*)path
{
  NSDictionary *attrs;
  BOOL result;
  NSFileManager *fmgr;

  result = NO;
  fmgr = [NSFileManager defaultManager];
  attrs = [fmgr fileAttributesAtPath:path traverseLink:YES];
  if (attrs)
    {
      if ([attrs objectForKey:NSFileType] == NSFileTypeDirectory)
        {
          NSArray      *dirContents;
          NSEnumerator *e2;
          NSString     *filename;
          NSDictionary  *attrs2;

          dirContents = [fmgr subpathsAtPath:path];
          e2 = [dirContents objectEnumerator];
          while ((filename = (NSString*)[e2 nextObject]))
            {
              NSString *tempName;
              NSString *lastPathComponent;

              lastPathComponent = [filename lastPathComponent];
              tempName = [path stringByAppendingPathComponent:filename];
              attrs2 = [[NSFileManager defaultManager] fileAttributesAtPath:tempName traverseLink:YES];
              if (attrs2)
                {
                  if ([attrs2 objectForKey:NSFileType] != NSFileTypeDirectory)
                    {
                      if (![filesToIgnore containsObject:lastPathComponent])
                        {
                          /* hide dot files, eventually a preference could be implemented */
                          if (![lastPathComponent hasPrefix: @"."])
                            {
                              [self addPath:tempName];
                              result = YES;
                            }
                        }
                    }
                }
            }
        }
      else
        {
          NSString *lastPathComponent;
              
          lastPathComponent = [path lastPathComponent];
          if (![filesToIgnore containsObject:lastPathComponent])
            {
              /* hide dot files, eventually a preference could be implemented */
              if (![lastPathComponent hasPrefix: @"."])
                {
                  [self addPath:path];
                  result = YES;
                }
            }
        }
    }
  return result;
}

- (void)dealloc
{
  [filesToIgnore release];
  [images release];
  [super dealloc];
}

- (void)addPath :(NSString*)path
{
  LMImage *image;

  image = [[LMImage alloc] init];
  [image setPath: path];
  [images addObject: image];
  [image release];
  [appController updateImageCount];
}

- (LMImage*)imageAtIndex :(NSUInteger)index
{
  return [images objectAtIndex:index];
}

- (NSString *)pathAtIndex :(NSUInteger)index
{
  return [[images objectAtIndex:index] path];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
  [images removeObjectAtIndex:index];
  [appController updateImageCount];
}

- (void)scrambleObjects
{
  NSMutableArray *newImages;
  
  newImages = [NSMutableArray arrayWithCapacity: [images count]];
  while ([images count] > 0)
    {
      unsigned i;
      
      /* get a rescaled random number */
      i = (unsigned)lround(((double)(unsigned long)random() / RAND_MAX) * ([images count]-1));
      [newImages addObject: [images objectAtIndex: i]];
      [images removeObjectAtIndex: i];
 
    }
  [images release];
  
  images = [newImages retain];
}

- (NSUInteger)imageCount
{
  return [images count];
}

/* methods implemented to follow the informal NSTableView protocol */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [images count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id theElement;

    theElement = nil;

    NSParameterAssert(rowIndex >= 0 && rowIndex < [images count]);
    if ([[aTableColumn identifier] isEqualToString:@"filename"])
        theElement = [[images objectAtIndex:rowIndex] name];
    else
        NSLog(@"unknown table column ident");
    return theElement;
}


- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
  NSPasteboard *pboard;
  BOOL result;

  result = NO;
  pboard = [info draggingPasteboard];
  if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
      NSEnumerator *e;
      NSArray *paths;
      NSString *filename;

      paths = [pboard propertyListForType:NSFilenamesPboardType];
      if ([paths count] > 0)
        {
          e = [paths objectEnumerator];
          while ((filename = (NSString*)[e nextObject]))
            {
              if (![filesToIgnore containsObject:[filename lastPathComponent]])
                result = YES;
            }
        }
    }
  if (result)
    return NSDragOperationEvery;
  return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
  BOOL result;
  NSPasteboard *pboard;
  NSString *filename;
  NSEnumerator *e;
  NSArray *paths;

  pboard = [info draggingPasteboard];
  result = NO;
  paths = [pboard propertyListForType:NSFilenamesPboardType];
  e = [paths objectEnumerator];
  while ((filename = (NSString*)[e nextObject]))
    {
      result = [self addPathAndRecurse:filename];
    }
  if (result)
    {
      [aTableView reloadData];
    }
  return result;
}

@end
