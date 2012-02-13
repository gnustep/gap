#import <Foundation/NSObject.h>

@class Archive;

#define COL_ID_NAME		@"name"
#define COL_ID_DATE		@"date"
#define COL_ID_SIZE		@"size"
#define COL_ID_PATH		@"path"
#define COL_ID_RATIO	@"ratio"

@interface TableViewDataSource : NSObject
{
  @private 
	Archive *_archive;
}

- (void)setArchive:(Archive *)archive;

@end
