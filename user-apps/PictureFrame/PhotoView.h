/* PhotoView

	Written: Adam Fedor <fedor@qwest.net>
	Date: May 2007
*/
#include "FrameView.h"


@interface PhotoView : NSImageView <FrameView>
{
  id inspector;
  
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

- (NSString *) nextPhoto;
- (NSString *) previousPhoto;

- (NSString *) currentAlbum;
- (NSDictionary *) currentPhoto;

@end
