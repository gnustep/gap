#import <Foundation/NSFileManager.h>

@interface NSFileManager (Custom)

- (NSString *)locateExecutable:(NSString *)aFilename;
- (NSString *)createTemporaryDirectory;
- (void)createDirectoryPathWithParents:(NSString *)aPath;

@end
