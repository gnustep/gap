#import <Foundation/NSObject.h>

@interface ArchiveService : NSObject
{
}

- (void)createZippedTarArchive:(NSPasteboard *)pboard userData:(NSString *)userData
	error:(NSString **)error;

@end
