#import <Foundation/NSObject.h>
#import "Archive.h"

@interface LhaArchive : Archive
{
}

- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path;
- (NSArray *)listContents;

+ (void)createArchive:(NSString *)archivePath withFiles:(NSArray *)filenames archiveType:(ArchiveType) archiveType;
@end
