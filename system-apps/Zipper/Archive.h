#import <Foundation/NSObject.h>

@class NSString, FileInfo, NSArray;

enum
{
	SortByPath = 1,
	SortBySize = 2,
	SortByFilename = 4,
	SortByDate = 8,
	SortByRatio = 16
};

@interface Archive : NSObject
{
  @private
    NSArray *_elements;
    NSString *_path;
	int _sortAttribute;
	NSComparisonResult _sortOrder;
}

+ (Archive *)newWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;
- (NSString *)path;

- (NSArray *)listContents;

- (void)sortByPath;
- (void)sortBySize;
- (void)sortByFilename;
- (void)sortByDate;
- (void)sortByRatio;
- (NSComparisonResult)sortOrder;

- (int)elementCount;
- (FileInfo *)elementAtIndex:(int)index;
- (NSArray *)elements;
- (void)setElements:(NSArray *)elements;

+ (BOOL)executableDoesExist;
+ (NSString *)unarchiveExecutable;
- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path;
- (NSData *)dataByRunningUnachiverWithArguments:(NSArray *)args;

+ (int)runUnarchiverWithArguments:(NSArray *)args inDirectory:(NSString *)workDir;
- (int)runUnarchiverWithArguments:(NSArray *)args;

+ (BOOL)hasRatio;
+ (BOOL)canExtractWithoutFullPath;
+ (NSString *)archiveType;
+ (NSData *)magicBytes;

+ (void)registerFileExtension:(NSString *)extension forArchiveClass:(Class)clazz;
+ (Class)classForFileExtension:(NSString *)fileExtension;
+ (NSArray *)allFileExtensions;
+ (NSArray *)allArchivers;

@end
