/*
 Project: FTP

 Copyright (C) 2005-2013 Riccardo Mottola

 Author: Riccardo Mottola

 Created: 2005-04-12

 Table class for file listing

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

#import "fileTable.h"
#import "fileElement.h"

/* we sort the already existing sorted array which contains only the keys to sort on */
NSComparisonResult compareDictElements(id e1, id e2, void *context)
{
  NSString *s1;
  NSString *s2;
  NSComparisonResult r;
  enum sortOrderDef sortOrder;

  s1 = [(NSDictionary *)e1 objectForKey: @"name"];
  s2 = [(NSDictionary *)e2 objectForKey: @"name"];
  sortOrder = *(enum sortOrderDef *)context;

  r = [s1 compare: s2];
  if (sortOrder == descending)
    {
      if (r == NSOrderedAscending)
	r = NSOrderedDescending;
      else if (r == NSOrderedDescending)
	r = NSOrderedAscending;
    }
  return r;
}

@implementation FileTable

- (void)initData:(NSArray *)fnames
{
  NSUInteger i;

  sortByIdent = nil;
  
  if (fileStructs)
    {
      [fileStructs release];
      [sortedArray release];
    }
  fileStructs = [[NSArray arrayWithArray:fnames] retain];
  sortedArray = [[NSMutableArray arrayWithCapacity: [fileStructs count]] retain];
  for (i = 0; i < [fileStructs count]; i++)
    {
      NSNumber *n;
      NSMutableDictionary *dict;
      FileElement *fe;

      fe = [fileStructs objectAtIndex: i];
      n = [NSNumber numberWithInt: i];
      dict = [NSMutableDictionary dictionary];
      [dict setObject: [fe filename] forKey: @"name"];
      [dict setObject: n forKey: @"row"];
      [sortedArray addObject: dict];
    }
  sortOrder = undefined;
}

- (void)dealloc
{
  [fileStructs release];
  [sortedArray release];
  [super dealloc];
}

- (void)clear
{
  [fileStructs release];
  fileStructs = nil;
  [sortedArray release];
  sortedArray = nil;
}
/** returns the object after resolving sorting */
- (FileElement *)elementAtIndex:(NSUInteger)index
{
  NSUInteger originalRow;

  originalRow = (NSUInteger)[[[sortedArray objectAtIndex: index] objectForKey: @"row"] intValue];
  return [fileStructs objectAtIndex:originalRow];
}

- (void)sortByIdent:(NSString *)idStr
{
  if ([idStr isEqualToString: sortByIdent])
    {
      if (sortOrder == ascending)
	sortOrder = descending;
      else
	sortOrder = ascending;
    }
  else
    {
      NSLog(@"Sort by: %@", idStr);
      sortOrder = ascending;
    }
  sortByIdent = idStr;
  [sortedArray sortUsingFunction:compareDictElements context:&sortOrder];
}



/* methods implemented to follow the informal NSTableView protocol */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [sortedArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id theElement;
    NSInteger originalRow;

    theElement = NULL;
    NSParameterAssert(rowIndex >= 0 && rowIndex < [sortedArray count]);
    originalRow = [[[sortedArray objectAtIndex: rowIndex] objectForKey: @"row"] intValue];
    if ([[aTableColumn identifier] isEqualToString:TAG_FILENAME])
        theElement = [[fileStructs objectAtIndex:originalRow] filename];
    else
        NSLog(@"unknown table column ident");
    return theElement;
}

@end

