//
//  Engine.m
//  StepSync-SL
//
//  Created by Riccardo Mottola on 19/10/2018.
//  Copyright 2018 GNUstep. All rights reserved.
//

#import "Engine.h"
#import "FileObject.h"
#import "FileMap.h"

#import <AppKit/NSProgressIndicator.h>


@implementation Engine

- (id) init
{
  if ((self = [super init]))
    {
    }
  return self;
}

- (void) dealloc
{
  [sourceMap release];
  [targetMap release];
  [targetMissingDirs release];
  [sourceMissingDirs release];
  [targetMissingFiles release];
  [sourceModFiles release];
  [targetModFiles release];
  [super dealloc];
}

- (BOOL)analyzed
{
  return analyzed;
}

- (void)setHandleDirectories:(BOOL)flag
{
  handleDirectories = flag;
}

- (void)setUpdateSource:(BOOL)flag
{
  updateSource = flag;
}

- (void)setInsertItems:(BOOL)flag
{
  insertItems = flag;
}

- (void)setUpdateItems:(BOOL)flag
{
  updateItems = flag;
}

- (void)setDeleteItems:(BOOL)flag
{
  deleteItems = flag;
}


- (void)setProgressIndicator:(NSProgressIndicator *)pi
{
  progressIndicator = pi;
}

- (BOOL)skipHiddenFolders
{
  return skipHiddenFolders;
}

- (void)setSkipHiddenFolders:(BOOL)flag
{
  skipHiddenFolders = flag;
}

- (BOOL)skipHiddenFiles
{
  return skipHiddenFiles;
}

- (void)setSkipHiddenFiles:(BOOL)flag
{
  skipHiddenFiles = flag;
}

- (BOOL)skipThumbFiles
{
  return skipThumbFiles;
}

- (void)setSkipThumbFiles:(BOOL)flag
{
  skipThumbFiles = flag;
}

- (void)setSourceRoot: (NSString *)path
{
  sourceRoot = path;
}

- (void)setTargetRoot: (NSString *)path
{
  targetRoot = path;
}


- (void)stopTask
{
  stopTask = YES;
}

- (NSMutableArray *)targetMissingDirs
{
  return targetMissingDirs;
}

- (NSMutableArray *)sourceMissingDirs
{
  return sourceMissingDirs;
}

- (NSMutableArray *)targetMissingFiles
{
  return targetMissingFiles;
}

- (NSMutableArray *)sourceMissingFiles
{
  return sourceMissingFiles;
}

- (NSMutableArray *)sourceModFiles
{
  return sourceModFiles;
}

- (NSMutableArray *)targetModFiles
{
  return targetModFiles;
}

- (FileMap *)sourceMap
{
  return sourceMap;
}

- (FileMap *)targetMap
{
  return targetMap;
}

- (void)analyze
{
  NSArray *sourceDirArray;
  NSArray *targetDirArray;
  NSString *dirStr;
  NSMutableDictionary *sourceFileDict;
  NSMutableDictionary *targetFileDict;
  NSEnumerator *en;
  FileObject *fileObj;
  NSAutoreleasePool *arp;

  arp = [NSAutoreleasePool new];
  stopTask = NO;
  [progressIndicator setIndeterminate:YES];
  [progressIndicator startAnimation:nil];

  [targetMissingFiles release];
  [sourceMissingFiles release];
  [targetModFiles release];
  [sourceModFiles release];
  
  
  [sourceMap release];
  sourceMap = [[FileMap alloc] init];
  [sourceMap setRootPath:sourceRoot];
  [sourceMap setSkipHiddenFolders:skipHiddenFolders];
  [sourceMap setSkipHiddenFiles:skipHiddenFiles];
  [sourceMap setSkipThumbFiles:skipThumbFiles];

  
  [sourceMap analyze];
  
  sourceFileDict = [sourceMap files];
  sourceDirArray = [sourceMap directories];
  
  [targetMap release];
  targetMap = [[FileMap alloc] init];
  [targetMap setRootPath:targetRoot];
  [targetMap setSkipHiddenFolders:skipHiddenFolders];
  [targetMap setSkipHiddenFiles:skipHiddenFiles];
  [targetMap setSkipThumbFiles:skipThumbFiles];
  
  [targetMap analyze];

  targetFileDict = [targetMap files];
  targetDirArray = [targetMap directories];

  targetMissingDirs = [NSMutableArray new];
  sourceMissingDirs = [NSMutableArray new];
  targetMissingFiles = [NSMutableArray new];
  sourceMissingFiles = [NSMutableArray new];
  targetModFiles = [NSMutableArray new];
  sourceModFiles = [NSMutableArray new];

  /* compare source against target directories */
  en = [sourceDirArray objectEnumerator];
  while ((dirStr = [en nextObject]) && !stopTask)
    {
      if ([targetDirArray indexOfObject:dirStr] == NSNotFound)
	[targetMissingDirs addObject:dirStr];
    }
  NSLog(@"target missing dirs: %@", targetMissingDirs);

  /* look for source missing directories */
  en = [targetDirArray objectEnumerator];
  while ((dirStr = [en nextObject]) && !stopTask)
    {
      if ([sourceDirArray indexOfObject:dirStr] == NSNotFound)
	[sourceMissingDirs addObject:dirStr];
    }
  NSLog(@"source missing dirs: %@", sourceMissingDirs);

  /* compare source against target
     find source modified and missing files */
  en = [sourceFileDict objectEnumerator];
  while ((fileObj = [en nextObject]) && !stopTask)
    {
      NSString *relPath;
      FileObject *fileObj2;

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

  /* look for source missing files */
  en = [targetFileDict objectEnumerator];
  while ((fileObj = [en nextObject]) && !stopTask)
    {
      NSString *relPath;
      FileObject *fileObj2;

      relPath = [fileObj relativePath];
      fileObj2 = [sourceFileDict objectForKey:relPath];
      if (!fileObj2)
	{
	  [sourceMissingFiles addObject:fileObj];
	}
    }
  
  NSLog(@"target missing: %@", targetMissingFiles);
  NSLog(@"source missing: %@", sourceMissingFiles);
  NSLog(@"target modified: %@", targetModFiles);
  NSLog(@"source modified: %@", sourceModFiles);

  analyzed = YES;
  [progressIndicator stopAnimation:nil];
  
  [arp release];
}

- (void)synchronize
{
  NSUInteger i;
  NSUInteger totalItems;
  NSFileManager *fm;

  NSAutoreleasePool *arp;

  arp = [NSAutoreleasePool new];

  fm = [NSFileManager defaultManager];

  stopTask = NO;
  [progressIndicator setIndeterminate:NO];
  
  totalItems = 0;
  if (updateSource || deleteItems)
    totalItems += [sourceMissingFiles count];
  
  if (!updateSource && !deleteItems)
    {
      [sourceMissingFiles release];
      sourceMissingFiles = nil;
      [targetModFiles release];
      targetModFiles = nil;
    }
    
  if (handleDirectories)
    {
      totalItems += [targetMissingDirs count];
      if (updateSource)
	totalItems += [sourceMissingDirs count];
    }
      
  totalItems += [targetMissingFiles count] + [targetModFiles count] + [sourceModFiles count];
  [progressIndicator setMinValue:0.0];
  [progressIndicator setMaxValue:(double)(totalItems-1)];

  if (handleDirectories)
    {
      if (updateSource)
	{
	  NSUInteger i;

	  /* create source missing directories */
	  for (i = 0; i < [sourceMissingDirs count] && !stopTask; i++)
	    {
	      NSString *fullPath;

	      fullPath = [sourceRoot stringByAppendingPathComponent:[sourceMissingDirs objectAtIndex:i]];
	      if (![fm createDirectoryAtPath:fullPath attributes:nil])
		{
		  NSLog(@"error creating: %@", fullPath);
		}
              [progressIndicator incrementBy:1.0];
	    }

	  if (deleteItems)
	    {
	      /* delete source excess directories */
	      for (i = 0; i < [targetMissingDirs count] && !stopTask; i++)
		{
		  NSString *fullPath;
		  
		  fullPath = [sourceRoot stringByAppendingPathComponent:[targetMissingDirs objectAtIndex:i]];
		  if (![fm removeFileAtPath:fullPath handler:nil])
		    {
		      NSLog(@"error removing: %@", fullPath);
		    }
                  [progressIndicator incrementBy:1.0];
		}
	    }
	}
      else
	{
	  NSUInteger i;

	  /* create target missing directories */
	  for (i = 0; i < [targetMissingDirs count] && !stopTask; i++)
	    {
	      NSString *fullPath;

	      fullPath = [targetRoot stringByAppendingPathComponent:[targetMissingDirs objectAtIndex:i]];
	      if (![fm createDirectoryAtPath:fullPath attributes:nil])
		{
		  NSLog(@"error creating: %@", fullPath);
		}
              [progressIndicator incrementBy:1.0];
	    }

	  if (deleteItems)
	    {
	      /* delete target excess directories */
	      for (i = 0; i < [sourceMissingDirs count] && !stopTask; i++)
		{
		  NSString *fullPath;
		  
		  fullPath = [targetRoot stringByAppendingPathComponent:[sourceMissingDirs objectAtIndex:i]];
		  if (![fm removeFileAtPath:fullPath handler:nil])
		    {
		      NSLog(@"error removing: %@", fullPath);
		    }
                  [progressIndicator incrementBy:1.0];
		}
	    }
	}
    }
  
  if (insertItems)
    {
      for (i = 0; i < [targetMissingFiles count] && !stopTask; i++)
	{
	  FileObject *fileObj;
	  NSString *newAbsolutePath;
	  NSDictionary *fAttr;

	  fileObj = [targetMissingFiles objectAtIndex:i];
	  [progressIndicator incrementBy:1.0];

	  /* TODO should recheck ? */
	  newAbsolutePath = [[targetMap rootPath] stringByAppendingPathComponent:[fileObj relativePath]];
	  [fm copyPath:[fileObj absolutePath] toPath:newAbsolutePath handler:nil];
	  fAttr = [fm fileAttributesAtPath:[fileObj absolutePath] traverseLink:NO];
	  [fm changeFileAttributes:fAttr atPath:newAbsolutePath];
	}
    }
  
  if (updateItems)
    {
      for (i = 0; i < [sourceModFiles count] && !stopTask; i++)
	{
	  FileObject *fileObj;
	  NSString *newAbsolutePath;
	  NSDictionary *fAttr;

	  fileObj = [sourceModFiles objectAtIndex:i];
	  [progressIndicator incrementBy:1.0];

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

  /* source is missing some files */
  if (deleteItems && !updateSource)
    {
      for (i = 0; i < [sourceMissingFiles count] && !stopTask; i++)
	{
	  FileObject *fileObj;

	  fileObj = [sourceMissingFiles objectAtIndex:i];
	  [progressIndicator incrementBy:1.0];

	  if([fm removeFileAtPath:[fileObj absolutePath] handler:nil])
	    {
	      NSLog(@"Error removing file: %@", [fileObj absolutePath]);
	    }
	}
    }
  /* copy the files to source */
  else if (updateSource)
    {
      if (insertItems)
        {
          for (i = 0; i < [sourceMissingFiles count] && !stopTask; i++)
            {
              FileObject *fileObj;
              NSString *newAbsolutePath;
              NSDictionary *fAttr;

              fileObj = [sourceMissingFiles objectAtIndex:i];
              [progressIndicator incrementBy:1.0];

              /* TODO should recheck ? */
              newAbsolutePath = [[sourceMap rootPath] stringByAppendingPathComponent:[fileObj relativePath]];
              [fm copyPath:[fileObj absolutePath] toPath:newAbsolutePath handler:nil];
              fAttr = [fm fileAttributesAtPath:[fileObj absolutePath] traverseLink:NO];
              [fm changeFileAttributes:fAttr atPath:newAbsolutePath];
            }
        }
      for (i = 0; i < [targetModFiles count] && !stopTask; i++)
	{
	  FileObject *fileObj;
	  NSString *newAbsolutePath;
	  NSDictionary *fAttr;

	  fileObj = [targetModFiles objectAtIndex:i];
	  [progressIndicator incrementBy:1.0];

	  /* TODO should recheck ? */
	  newAbsolutePath = [[sourceMap rootPath] stringByAppendingPathComponent:[fileObj relativePath]];
	  if([fm removeFileAtPath:newAbsolutePath handler:nil])
	    {
	      [fm copyPath:[fileObj absolutePath] toPath:newAbsolutePath handler:nil];
	      fAttr = [fm fileAttributesAtPath:[fileObj absolutePath] traverseLink:NO];
	      [fm changeFileAttributes:fAttr atPath:newAbsolutePath];
	    }
	}
    }

  [arp release];
}


@end
