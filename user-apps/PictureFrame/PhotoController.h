/* PhotoController

	Written: Adam Fedor <fedor@qwest.net>
	Date: May 2007
*/
#include "FrameDisplay.h"

@class PhotoView;

@interface PhotoController : NSObject <FrameDisplay>
{
  id inspector;
  PhotoView *photoView;
  
  NSDictionary *photoAlbums;
  NSDictionary *currentAlbum;
  NSDictionary *currentPhotoInfo;
  NSEnumerator *albumEnum;
  NSEnumerator *imageEnum;
  NSDirectoryEnumerator *photoDirEnum;
  NSMutableArray *lastPhotos;
  int lastPhotoIndex;
  int verbose;
}

+ (PhotoController *)sharedPhotoController;
- (void) setVerbose: (int)state;
- (NSString *) previousPhoto;

- (NSString *) currentAlbum;
- (NSDictionary *) currentPhotoInfo;

@end
