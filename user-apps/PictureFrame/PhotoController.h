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
  NSDictionary *currentPhoto;
  NSEnumerator *albumEnum;
  NSEnumerator *imageEnum;
  NSDirectoryEnumerator *photoDirEnum;
  NSMutableArray *lastPhotos;
  int lastPhotoIndex;
  BOOL verbose;
}

+ (PhotoController *)sharedPhotoController;
- (NSString *) nextPhoto;
- (NSString *) previousPhoto;

- (NSString *) currentAlbum;
- (NSDictionary *) currentPhoto;

@end
