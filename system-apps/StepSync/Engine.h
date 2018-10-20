//
//  Engine.h
//  StepSync-SL
//
//  Created by Riccardo Mottola on 19/10/2018.
//  Copyright 2018 GNUstep. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSProgressIndicator;
@class FileMap;

@interface Engine : NSObject
{
  NSProgressIndicator *progressIndicator;
  
  BOOL analyzed;
  BOOL analyzeRunning;
  BOOL syncRunning;
  BOOL stopTask;
  FileMap *sourceMap;
  FileMap *targetMap;
  NSMutableArray *targetMissingDirs;
  NSMutableArray *sourceMissingDirs;
  NSMutableArray *targetMissingFiles;
  NSMutableArray *sourceMissingFiles;
  NSMutableArray *sourceModFiles;
  NSMutableArray *targetModFiles;

  BOOL handleDirectories;
  BOOL updateSource;
  BOOL insertItems;
  BOOL updateItems;
  BOOL deleteItems;
  BOOL skipHiddenFolders;
  BOOL skipHiddenFiles;
  BOOL skipThumbFiles;
  NSString *sourceRoot;
  NSString *targetRoot;
}

- (BOOL)analyzed;
- (void)setHandleDirectories:(BOOL)flag;
- (void)setUpdateSource:(BOOL)flag;
- (void)setInsertItems:(BOOL)flag;
- (void)setUpdateItems:(BOOL)flag;
- (void)setDeleteItems:(BOOL)flag;

- (void)setProgressIndicator:(NSProgressIndicator *)pi;
- (BOOL)skipHiddenFolders;
- (void)setSkipHiddenFolders:(BOOL)flag;
- (BOOL)skipHiddenFiles;
- (void)setSkipHiddenFiles:(BOOL)flag;
- (BOOL)skipThumbFiles;
- (void)setSkipThumbFiles:(BOOL)flag;

- (void)setSourceRoot: (NSString *)path;
- (void)setTargetRoot: (NSString *)path;

- (FileMap *)sourceMap;
- (FileMap *)targetMap;


- (void)stopTask;

- (NSMutableArray *)targetMissingDirs;
- (NSMutableArray *)sourceMissingDirs;
- (NSMutableArray *)targetMissingFiles;
- (NSMutableArray *)sourceMissingFiles;
- (NSMutableArray *)sourceModFiles;
- (NSMutableArray *)targetModFiles;

- (void)analyze;
- (void)synchronize;

@end
