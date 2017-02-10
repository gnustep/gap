/* 
 Project: StepSync
 AppController.m
 
 Copyright (C) 2017 Riccardo Mottola
 
 Author: Riccardo Mottola
 
 Created: 2017-02-02
 
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

#import "AppController.h"
#import "FileMap.h"
#import "FileObject.h"

@implementation AppController

- (NSString *)formatSize:(unsigned long long)size
{
  NSString *result;
  double dSize;

  result = nil;
  if (size < 1024)
    {
      result = [NSString stringWithFormat:@"%lu B", size];
    }
  else
    {
      dSize = (double)size / 1024;
      if (dSize < 1024)
	{
	  result = [NSString stringWithFormat:@"%.1lf KB", dSize];
	}
      else
	{
	  dSize = dSize / 1024;
	  if (dSize < 1024)
	    {
	      result = [NSString stringWithFormat:@"%.1lf MB", dSize];
	    }
	  else
	    {
	      dSize = dSize / 1024;
	      if (dSize < 1024)
		{
		  result = [NSString stringWithFormat:@"%.1lf GB", dSize];
		}
	      else
		{
		  dSize = dSize / 1024;
		  result = [NSString stringWithFormat:@"%.1lf TB", dSize];
		}
	    }
	}
    }
  
  return result;
}

- (void)awakeFromNib
{
  /*
  [analyzeButton setEnabled:NO];
  [syncButton setEnabled:NO];
  */
}

- (IBAction)setSourcePath:(id)sender
{
  NSOpenPanel *openPanel;
  
  openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  if ([openPanel runModal] == NSOKButton)
    {
      NSString *fileName;
    
      fileName = [openPanel filename];
      [sourcePathField setStringValue:fileName];
    }
}

- (IBAction)setTargetPath:(id)sender
{
  NSOpenPanel *openPanel;
  
  openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  if ([openPanel runModal] == NSOKButton)
    {
      NSString *fileName;
    
      fileName = [openPanel filename];
      [targetPathField setStringValue:fileName];
    }  
}

- (IBAction)analyzeAction:(id)sender
{
  NSString *sourceRoot;
  NSString *targetRoot;
  NSMutableDictionary *sourceFileDict;
  NSMutableDictionary *targetFileDict;
  NSEnumerator *en;
  FileObject *fileObj;
  unsigned long long sourceSize;
  unsigned long long targetSize;
  
  [progressBar setIndeterminate:YES];
  [progressBar startAnimation:nil];

  [targetMissingFiles release];
  [sourceMissingFiles release];
  [targetModFiles release];
  [sourceModFiles release];
  
  sourceRoot = [sourcePathField stringValue];
  targetRoot = [targetPathField stringValue];
  
  [sourceMap release];
  sourceMap = [[FileMap alloc] init];
  [sourceMap setRootPath:sourceRoot];
  [sourceMap analyze];
  [sourceDirNumberField setStringValue:[[NSNumber numberWithUnsignedInt:[[sourceMap directories] count]] description]];
  [sourceFileNumberField setStringValue:[[NSNumber numberWithUnsignedInt:[[sourceMap files] count]] description]];
  sourceFileDict = [sourceMap files];
  
  [targetMap release];
  targetMap = [[FileMap alloc] init];
  [targetMap setRootPath:targetRoot];
  [targetMap analyze];
  [targetDirNumberField setStringValue:[[NSNumber numberWithUnsignedInt:[[targetMap directories] count]] description]];
  [targetFileNumberField setStringValue:[[NSNumber numberWithUnsignedInt:[[targetMap files] count]] description]];
  targetFileDict = [targetMap files];

  targetMissingFiles = [NSMutableArray new];
  sourceMissingFiles = [NSMutableArray new];
  targetModFiles = [NSMutableArray new];
  sourceModFiles = [NSMutableArray new];

  /* compare source against target
     find source modified and missing files */
  en = [sourceFileDict objectEnumerator];
  sourceSize = 0;
  while ((fileObj = [en nextObject]))
    {
      NSString *relPath;
      FileObject *fileObj2;

      sourceSize += [fileObj size];
      relPath = [fileObj relativePath];
      fileObj2 = [targetFileDict objectForKey:relPath];
      if (fileObj2)
	{
	  NSComparisonResult cr;

	  cr = [[fileObj modifiedDate] compare:[fileObj2 modifiedDate]];
	  if (cr == NSOrderedDescending)
	    [sourceModFiles addObject:fileObj];
	  else if (cr == NSOrderedAscending)
	    [targetModFiles addObject:fileObj];
	}
      else
	{
	  [targetMissingFiles addObject:fileObj];
	}
    }
  [sourceSizeField setStringValue:[self formatSize:sourceSize]];

  /* look for source missing files */
  en = [targetFileDict objectEnumerator];
  targetSize = 0;
  while ((fileObj = [en nextObject]))
    {
      NSString *relPath;
      FileObject *fileObj2;

      relPath = [fileObj relativePath];
      targetSize += [fileObj size];
      fileObj2 = [sourceFileDict objectForKey:relPath];
      if (!fileObj2)
	{
	  [sourceMissingFiles addObject:fileObj];
	}
    }
  [targetSizeField setStringValue:[self formatSize:targetSize]];
  
  NSLog(@"target missing: %@", targetMissingFiles);
  NSLog(@"source missing: %@", sourceMissingFiles);
  NSLog(@"target modified: %@", targetModFiles);
  NSLog(@"source modified: %@", sourceModFiles);

  /* TODO handle directories */

  analyzeRunning = NO;
  analyzed = YES;
  [progressBar stopAnimation:nil];
}

- (IBAction)syncAction:(id)sender
{
  NSUInteger i;
  NSUInteger totalItems;
  NSFileManager *fm;
  BOOL handleDirectories;
  BOOL updateSource;
  BOOL insertItems;
  BOOL updateItems;
  BOOL deleteItems;

  fm = [NSFileManager defaultManager];
  if (!analyzed)
    [self analyzeAction:sender];

  syncRunning = YES;
  [progressBar setIndeterminate:NO];
  
  handleDirectories = [handleDirectoriesCheck state] == NSOnState;
  updateSource = [updateSourceCheck state] == NSOnState;
  insertItems = [insertItemsCheck state] == NSOnState;
  updateItems = [updateItemsCheck state] == NSOnState;
  deleteItems = [deleteItemsCheck state] == NSOnState;


  if (!updateSource)
    {
      [sourceMissingFiles release];
      sourceMissingFiles = 0;
      [targetModFiles release];
      targetModFiles = 0;
      /* TODO handle directories */
    }
    
  if (handleDirectories)
    {
        /* TODO handle directories */
    }
      
  totalItems = [targetMissingFiles count] + [sourceMissingFiles count] + [targetModFiles count] + [sourceModFiles count];
  [progressBar setMinValue:0.0];
  [progressBar setMaxValue:(double)totalItems];

  if (insertItems)
    {
      for (i = 0; i < [targetMissingFiles count]; i++)
	{
	  FileObject *fileObj;
	  NSString *newAbsolutePath;
	  NSDictionary *fAttr;

	  fileObj = [targetMissingFiles objectAtIndex:i];
	  [progressBar incrementBy:1.0];

	  /* TODO should recheck ? */
	  newAbsolutePath = [[targetMap rootPath] stringByAppendingPathComponent:[fileObj relativePath]];
	  [fm copyPath:[fileObj absolutePath] toPath:newAbsolutePath handler:nil];
	  fAttr = [fm fileAttributesAtPath:[fileObj absolutePath] traverseLink:NO];
	  [fm changeFileAttributes:fAttr atPath:newAbsolutePath];
	}
    }
  
  if (updateItems)
    {
      for (i = 0; i < [sourceModFiles count]; i++)
	{
	  FileObject *fileObj;
	  NSString *newAbsolutePath;
	  NSDictionary *fAttr;

	  fileObj = [sourceModFiles objectAtIndex:i];
	  [progressBar incrementBy:1.0];

	  /* TODO should recheck ? */
	  newAbsolutePath = [[targetMap rootPath] stringByAppendingPathComponent:[fileObj relativePath]];
	  if([fm removeFileAtPath:newAbsolutePath handler:nil])
	    {
	      [fm copyPath:[fileObj absolutePath] toPath:newAbsolutePath handler:nil];
	      fAttr = [fm fileAttributesAtPath:[fileObj absolutePath] traverseLink:NO];
	      [fm changeFileAttributes:fAttr atPath:newAbsolutePath];
	    }
	}
    }
 
  if (deleteItems)
    {
      for (i = 0; i < [sourceMissingFiles count]; i++)
	{
	  FileObject *fileObj;

	  fileObj = [sourceMissingFiles objectAtIndex:i];
	  [progressBar incrementBy:1.0];

	  if([fm removeFileAtPath:[fileObj absolutePath] handler:nil])
	    {
	    }
	}
    }
  
  syncRunning = NO;
}


@end
