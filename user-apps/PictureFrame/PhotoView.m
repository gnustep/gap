/* PhotoView

Written: Adam Fedor <fedor@qwest.net>
Date: May 2007

*/
#import "PhotoView.h"
#import "PreferencesController.h"
#import "GNUstep.h"

#define dfltmgr [NSUserDefaults standardUserDefaults]

NSString *DCurrentPhoto = @"CurrentPhoto";
NSString *DCurrentAlbum = @"CurrentAlbum";

@implementation PhotoView

- (id) initWithFrame: (NSRect)aFrame
{
  [super initWithFrame: aFrame];

  [self setEditable: NO];
  verbose = YES;
  lastPhotos = RETAIN([NSMutableArray arrayWithCapacity: 100]);
  lastPhotoIndex = 0;
  return self;
}

- (void) dealloc
{
  TEST_RELEASE(photoAlbums);
  TEST_RELEASE(albumEnum);
  TEST_RELEASE(imageEnum);
  TEST_RELEASE(currentAlbum);
  TEST_RELEASE(currentPhoto);
  RELEASE(photoDirEnum);
  RELEASE(lastPhotos);
  [super dealloc];
}

- (NSString *) currentAlbum
{
  NSString *a;
  if (currentAlbum)
    a = [currentAlbum objectForKey: @"AlbumName"];
  else
    a = @"";
  return a;
}

- (NSDictionary *) currentPhoto
{
  return currentPhoto;
}

- (BOOL) fileIsImage: (NSString *)file
{
  /* FIXME: Need to make this better */
  if ([[file pathExtension] isEqual: @"JPG"] || [[file pathExtension] isEqual: @"jpg"])
    return YES;
  return NO;
}

/* We are looking in a directory structure that contains iPhoto albums, so we look at the iPhoto meta-data about Albums and images
*/
- (NSDictionary *) nextAlbum: (NSString *)newDir
{
  BOOL done;
  NSString *str;
  NSString *album;
  NSDictionary *albumList;

  DESTROY(imageEnum);
  DESTROY(currentAlbum);
  DESTROY(currentPhoto);
  if (newDir)
    {
      /* New directory to look at */
      str = [newDir stringByAppendingPathComponent: @"AlbumData.xml"];
      str = [NSString stringWithContentsOfFile: str];
      TEST_RELEASE(photoAlbums);
      TEST_RELEASE(albumEnum);
      NS_DURING
	/* Er... I have one iPhoto album that Cocoa can't read! */
	photoAlbums = RETAIN([str propertyList]);
      NS_HANDLER
	NSLog(@"EXCEPTION while reading iPhoto album xml: %@",localException);
	photoAlbums = nil;
	albumEnum = nil;
	return nil;
      NS_ENDHANDLER
      albumList = [photoAlbums objectForKey: @"List of Albums"];
      albumEnum = RETAIN([albumList objectEnumerator]);
      /* Don't need the rest of the files in this directory */
      [photoDirEnum skipDescendents];
    }
  
  done = 0;
  album = [dfltmgr objectForKey: DAlbum];
  while (!done)
    {
      currentAlbum = [albumEnum nextObject];
      if (currentAlbum == nil)
	{
	  /* We're out of photos in this directory. Just punt and nextPhoto: will get the next directory */
	  [dfltmgr removeObjectForKey: DCurrentAlbum];
	  DESTROY(photoAlbums);
	  DESTROY(albumEnum);
	  return nil;
	}
      str = [currentAlbum objectForKey: @"AlbumName"];
      /* Skip default albums */
      if ([str isEqual: @"Library"] == NO && [str isEqual: @"Last Roll"] == NO && [str isEqual: @"Last 12 Months"] == NO && [str isEqual: @"Photo Library"] == NO)
	done = 1;
      /* Check if we have a specific album */
      if (album && [album isEqual: @"Albums"] == NO 
          && [str rangeOfString: album].location == NSNotFound)
	done = 0;
    }
  imageEnum = RETAIN([[currentAlbum objectForKey: @"KeyList"] objectEnumerator]);
  RETAIN(currentAlbum);
  [dfltmgr setObject: [currentAlbum objectForKey: @"AlbumName"] forKey: DCurrentAlbum];
  NSLog(@"Starting Album: %@", [currentAlbum objectForKey: @"AlbumName"]);
  return currentAlbum;
}

/* Since we probably copied the AlbumData.xml from a Mac to our picture
   frame, update the HomeDirectory in the path to the picture frame dir
*/
- (NSString *) convertPhotoPath: (NSString *)photo
{
  NSRange range;
  range = [photo rangeOfString: @"Pictures"];
  if (range.location != NSNotFound)
    {
      range.location += range.length + 1;
      range.length = [photo length] - range.location;
      photo = [photo substringWithRange: range];
      photo = [[dfltmgr objectForKey: DPhotoPath] stringByAppendingPathComponent: photo];
    }
  return photo;
}

- (BOOL) photoMatchesAlbumKeyword: (NSDictionary *)photo
{
  NSEnumerator *kenum;
  NSString *keyword, *key, *k;
  NSDictionary *keys;
  NSArray *photoKeys;
  NSRange range;
  keyword = [dfltmgr objectForKey: DKeyword];
  /* Always match if there is no search string */
  if (keyword == nil || [keyword length] == 0)
    return YES;

  keys = [photoAlbums objectForKey: @"List of Keywords"];
  kenum = [keys keyEnumerator];
  key = nil;
  while ((k = [kenum nextObject]))
    {
      NSString *str = [keys objectForKey: k];
      range = [str rangeOfString: keyword];
      /* FIXME: Only matches one key */
      if (range.location != NSNotFound)
        key = k;
    }
  photoKeys = [photo objectForKey: @"Keywords"];
  if (key && photoKeys && [photoKeys indexOfObject: key] != NSNotFound)
    return YES;
  /* Didn't find a matching keyword, look for a matching comment */
  k = [photo objectForKey: @"Comment"];
  if (k && [k length] > 0)
    {
      range = [k rangeOfString: keyword];
      if (range.location != NSNotFound)
        return YES;
    }
  return NO;
}

/* We found an iPhoto Album. Now find the next photo in that album.
*/
- (NSString *) nextAlbumPhoto: (NSString *)newDir
{
  BOOL isDir;
  NSDictionary *imageList, *nextPhoto;
  NSString *imageKey;
  NSString *photo = nil;
  NSFileManager *fmgr = [NSFileManager defaultManager];
  
  if (currentAlbum == nil || newDir)
    [self nextAlbum: newDir];
  if (currentAlbum == nil)
    return nil;

  imageList = [photoAlbums objectForKey: @"Master Image List"];
  DESTROY(currentPhoto);
  while (photo == nil)
    {
      imageKey = [imageEnum nextObject];
      if (imageKey == nil)
        {
	  [self nextAlbum: nil];
	  if (currentAlbum == nil)
	    {
	      [dfltmgr removeObjectForKey: DCurrentPhoto];
	      return nil;
	    }
	  imageKey = [imageEnum nextObject];
        }          
      nextPhoto = [imageList objectForKey: imageKey];
      if ([self photoMatchesAlbumKeyword: nextPhoto] == NO)
        {
	  continue;
	}
      photo = [nextPhoto objectForKey: @"ImagePath"];
      photo = [self convertPhotoPath: photo];
      if ([fmgr fileExistsAtPath: photo isDirectory: &isDir] == NO)
        photo = nil;
    }
  [dfltmgr setObject: photo forKey: DCurrentPhoto];
  [lastPhotos addObject: photo];
  lastPhotoIndex++;
  currentPhoto = RETAIN(nextPhoto);
  if (verbose)
    NSLog(@"Album photo %@", photo);
  return photo;
}

- (NSString *) nextPhoto
{
  int loops;
  NSString *photo, *file;
  NSString *album;
  NSString *picDir;
  NSFileManager *fmgr = [NSFileManager defaultManager];
  picDir = [dfltmgr objectForKey: DPhotoPath];
  if (photoDirEnum == nil)
    {
      photoDirEnum = RETAIN([fmgr enumeratorAtPath: picDir]);
    }
  
  if (lastPhotoIndex < [lastPhotos count])
    {
    /* Work through our previous photos that the user requested */
    return [lastPhotos objectAtIndex: lastPhotoIndex++];
    }
  if ([lastPhotos count] > 200)
    {
    /* Undo limit */
    [lastPhotos removeObjectsInRange: NSMakeRange(0, 100)];
    lastPhotoIndex = [lastPhotos count];
    }
  
  if (photoAlbums)
    {
      return [self nextAlbumPhoto: nil];
    }
  
  loops = 0;
  photo = nil;
  album = [dfltmgr objectForKey: DAlbum];
  while (photo == nil)
    {
      BOOL isDir;
      NSRange range;
      file = [photoDirEnum nextObject];
      if (file == nil)
        {
          /* Start over */
	  [photoDirEnum release];
          photoDirEnum = [[fmgr enumeratorAtPath: picDir] retain];
          file = [photoDirEnum nextObject];
	  /* Don't go into an infinite loop if nothing's there,
	     or we've been here several times without finding anything
	     (perhaps album is non-existant).  */
	  if (file ==  nil || loops > 2)
	    return nil;
	  loops++;
        }
      file = [picDir stringByAppendingPathComponent: file];
      [fmgr fileExistsAtPath: file isDirectory: &isDir];
      range.location = 0;
      if (isDir == YES)
        {
	  if (album)
	    {
	      NSString *albumPath;
	      albumPath = [file stringByAppendingPathComponent: @"AlbumData.xml"];
	      if ([fmgr fileExistsAtPath: albumPath isDirectory: &isDir])
		{
		  /* Use iPhoto albums to look for pictures */
		  return [self nextAlbumPhoto: file];
		}
	    }
          range.location = NSNotFound;
        }
      else if (album && [album length] > 0)
        range = [file rangeOfString: album];
      if (range.location != NSNotFound && [self fileIsImage: file])
        photo = file;
    }
  if (photo)
    {
      NSRange range;
      range.location = [picDir length] + 1;
      range.length = [photo length] - [picDir length] - 1;
      [dfltmgr setObject: [photo substringWithRange: range] forKey: DCurrentPhoto];
      TEST_RELEASE(currentPhoto);
      currentPhoto = [NSDictionary dictionaryWithObjectsAndKeys: photo, @"ImagePath", nil];
      RETAIN(currentPhoto);
      [lastPhotos addObject: photo];
      lastPhotoIndex++;
    }
  if (verbose)
    NSLog(@"Found photo %@", photo);
  return photo;
}

/* Find where we left off last */
- (NSString *) gotoCurrentPhoto;
{
  int i;
  NSString *file, *photo, *album, *reqalbum;
  
  photo = [dfltmgr objectForKey: DCurrentPhoto];
  album = [dfltmgr objectForKey: DCurrentAlbum];
  /* Make sure defaults haven't changed */
  reqalbum = [dfltmgr objectForKey: DAlbum];
  if (reqalbum && [reqalbum isEqual: @"Albums"] == NO
      && [album rangeOfString: reqalbum].location == NSNotFound)
    {
      album = nil;
      photo = nil;
      [dfltmgr removeObjectForKey: DCurrentAlbum];
      [dfltmgr removeObjectForKey: DCurrentPhoto];
    }

  verbose = NO;
  i = 0;
  if (photo && album == nil)
    {
      /* Start where we left off */
      while (1)
	{
	  file = [photoDirEnum nextObject];
	/* file will be nil at the end of an album, so make sure we can continue on to the next album */
	if (file == nil && i < 3)
	  {
	  i++;
	  continue;
	  }
	if (file != nil)
	  i = 0;
	  if ([photo isEqual: file] || file == nil)
	    break;
	}
    }
  else if (photo)
    {
      while(1)
        {
	  file = [self nextPhoto];
	/* file will be nil at the end of a dir, so make sure we can continue on to the next dir
	    but not forever. */
	if (file == nil && i <= 3)
	  {
	  i++;
	  continue;
	  }
	  if (file == nil || [photo isEqual: file])
	    break;
        }
    }
  if (photo && file == nil)
    {
      /* Couldn't find the file, just start at the beginning */
      DESTROY(photoDirEnum);
      [dfltmgr removeObjectForKey: DCurrentAlbum];
      [dfltmgr removeObjectForKey: DCurrentPhoto];
    }
  verbose = YES;
  return photo;
}

- (NSString *) previousPhoto
{
  NSString *photo;
  /* Subtract 2 - the current one is stored in the last location */
  lastPhotoIndex -= 2;
  if (lastPhotoIndex < 0)
    lastPhotoIndex = 0;
  photo = [lastPhotos objectAtIndex: lastPhotoIndex++];
  NSLog(@"Previous Photo %d: %@", lastPhotoIndex-1, photo);
  return photo;
}

/* FrameView Protocol */

- (void) oneStep
{
  int i = 0;
  NSImage *current = nil;
  if (photoDirEnum == nil)
    [self gotoCurrentPhoto];
  while (current == nil && i++ < 5)
    {
      NSString *photo = [self nextPhoto];
      if (photo)
        current = [[NSImage alloc] initWithContentsOfFile: photo];
      AUTORELEASE(current);
    }
  if (current == nil)
    {
      NSLog(@"No images to display");
      return;
    }
  [self setImage: current];
}

- (void) reverseStep
{
  NSImage *current = nil;
  NSString *photo = [self previousPhoto];
  if (photo)
    {
      current = [[NSImage alloc] initWithContentsOfFile: photo];
      AUTORELEASE(current);
    }
  if (current)
    [self setImage: current];
}

- (NSTimeInterval) animationDelayTime
{
  return 0;
}

// inspector methods...
- (NSView *) inspector: (id)sender
{
  return NULL;
}

- (void) inspectorInstalled
{
}

- (void) inspectorWillBeRemoved
{
}


// window methods...
- (BOOL) useBufferedWindow
{
  return YES;
}


// notification methods..
- (void) willEnterScreenSaverMode
{
}

- (void) enteredScreenSaverMode
{
}

- (void) willExitScreenSaverMode
{
}


@end
