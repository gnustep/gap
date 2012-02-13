#import <Foundation/NSObject.h>
#import "Archive.h"

@interface LzxArchive : Archive
{
}

- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path;
- (NSArray *)listContents;

@end
