//
//  Engine.h
//  StepSync-SL
//
//  Created by Riccardo Mottola on 19/10/2018.
//  Copyright 2018-2019 GNUstep. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSProgressIndicator;
@class FileMap;
@class FileArray;

@interface Engine : NSObject
{
  NSProgressIndicator *progressIndicator;
  
  BOOL analyzed;
  BOOL stopTask;
  FileMap *sourceMap;
  FileMap *targetMap;
  NSMutableArray *targetMissingDirs;
  NSMutableArray *sourceMissingDirs;
  FileArray *targetMissingFiles;
  FileArray *sourceMissingFiles;
  FileArray *sourceModFiles;
  FileArray *targetModFiles;
  FileArray *sizeDiffFiles;

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
- (FileArray *)targetMissingFiles;
- (FileArray *)sourceMissingFiles;
- (FileArray *)sourceModFiles;
- (FileArray *)targetModFiles;
- (FileArray *)sizeDiffFiles;

- (void)analyze;
- (void)synchronize;

@end
