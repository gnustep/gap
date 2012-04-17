/* 
   Project: LaternaMagica
   FileTable.m

   Copyright (C) 2006-2012 Riccardo Mottola

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
        fileNames = [[NSMutableArray arrayWithCapacity:5] retain];
        filePaths = [[NSMutableArray arrayWithCapacity:5] retain];
    }
    return self;
}

- (void)dealloc
{
    [fileNames release];
    [filePaths release];
    [super dealloc];
}

- (void)addPath :(NSString*)path
{
    [filePaths addObject:path];
    [fileNames addObject:[path lastPathComponent]];
}

- (NSString *)pathAtIndex :(int)index
{
    return [filePaths objectAtIndex:index];
}

- (void)removeObjectAtIndex:(int)index
{
    [fileNames removeObjectAtIndex:index];
    [filePaths removeObjectAtIndex:index];
}

- (void)scrambleObjects
{
  NSMutableArray *newNames;
  NSMutableArray *newPaths;
  
  newNames = [NSMutableArray arrayWithCapacity: [fileNames count]];
  newPaths = [NSMutableArray arrayWithCapacity: [filePaths count]];
  while ([fileNames count] > 0)
    {
      unsigned i;
      
      /* get a rescaled random number */
      i = (unsigned)lround(((double)(unsigned long)random() / RAND_MAX) * ([fileNames count]-1));
      [newNames addObject: [fileNames objectAtIndex: i]];
      [fileNames removeObjectAtIndex: i];
      [newPaths addObject: [filePaths objectAtIndex: i]];
      [filePaths removeObjectAtIndex: i];
    }
  [fileNames release];
  [filePaths release];
  
  fileNames = [newNames retain];
  filePaths = [newPaths retain];
}


/* methods implemented to follow the informal NSTableView protocol */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [fileNames count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id theElement;

    theElement = nil;

    NSParameterAssert(rowIndex >= 0 && rowIndex < [fileNames count]);
    if ([[aTableColumn identifier] isEqualToString:@"filename"])
        theElement = [fileNames objectAtIndex:rowIndex];
    else
        NSLog(@"unknown table column ident");
    return theElement;
}
@end
