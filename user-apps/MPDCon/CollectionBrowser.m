/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "CollectionBrowser.h"
#include "Strings.h"

@interface CollectionBrowser(Private)
- (void) _refreshView:(id) sender;
@end

@implementation CollectionBrowser
+ (id) sharedCollectionBrowser
{
  static CollectionBrowser *_sharedCollectionBrowser = nil;

  if (! _sharedCollectionBrowser)
    {
      _sharedCollectionBrowser = [[CollectionBrowser
                                       allocWithZone: [self zone]] init];
    }

  return _sharedCollectionBrowser;
}

- (id) init
{
  if ((self = [self initWithWindowNibName: @"CollectionBrowser"]) != nil)
    {
      [self setWindowFrameAutosaveName: @"CollectionBrowser"];
      mpdController = [MPDController sharedMPDController];
      directories = [[mpdController getAllDirectories] retain];
      dirhierarchy = [[NSMutableDictionary alloc] init];
      dirmetadata = [[NSMutableDictionary alloc] init];
    }
  return self;
}

- (void) dealloc
{
  [mpdController release];
  [directories release];
  [dirhierarchy release];
  [dirmetadata release];

  [super dealloc];
}

/* --------------------
   - Playlist Methods -
   --------------------*/

- (void) addSelected: (id)sender
{
  NSEnumerator *songEnum = [[browser selectedCells] objectEnumerator];
  NSCell *selectedSong;
  NSString *path = [browser pathToColumn:[browser selectedColumn]];
  while ((selectedSong = [songEnum nextObject]) != nil)
    {
      [NSString pathWithComponents:
		[NSArray arrayWithObjects: path, [selectedSong objectValue], nil]]);
	
      [[MPDController sharedMPDController]
	  addTrack: [[NSString pathWithComponents:
	    [NSArray arrayWithObjects: path, [selectedSong objectValue], nil]]
		substringFromIndex:1]];
    }
}

/* ---------------
   - Gui Methods -
   ---------------*/

- (void) awakeFromNib
{
  NSNotificationCenter *defCenter;

  defCenter = [NSNotificationCenter defaultCenter];

  [defCenter addObserver: self
                selector: @selector(_refreshView:)
                    name: ShownCollectionChangedNotification
                  object: nil];

  [browser setPath:@"/"];
  [browser setDelegate: self];
}

- (void) updateCollection: (id)sender
{
  [[MPDController sharedMPDController] updateCollection];
}

/* -----------------------
   - NSBrowser Delegates -
   -----------------------*/

- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
  NSInteger count;
  NSEnumerator *dirEnum, *fileEnum;
  NSString *dir, *file;
  NSMutableArray *tmpArray = [NSMutableArray new];
  NSSet *uniqueElements;
  NSArray *files;

  NSString *ptc = [sender pathToColumn: column];
  NSString *rptc = [ptc substringFromIndex:1];
  dirEnum = [directories objectEnumerator];

  while ((dir = [dirEnum nextObject]) != nil)
    {
      if ([[dir pathComponents] count] > column)
        {
	  NSString *tmpObject = [NSString stringWithFormat:@"%@", [[dir pathComponents] objectAtIndex:column]];
          if ([dir hasPrefix:rptc])
            {
              if ([tmpArray indexOfObject:dir] == NSNotFound)
                {
                  [tmpArray addObject:tmpObject];

                }
            }
          if ([rptc length] == 0 && column == 0)
            {
              if (![tmpArray containsObject:tmpObject])
                {
                  [tmpArray addObject:tmpObject];
                }
            }
          [dirmetadata setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%@%@", ptc,tmpObject]];
        }
    }

  uniqueElements = [NSSet setWithArray:tmpArray];
  [tmpArray release];
  tmpArray = [NSMutableArray arrayWithArray: [uniqueElements allObjects]];
  [tmpArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  files = [mpdController getAllFilesInDirectory:rptc];
  [tmpArray addObjectsFromArray: files];
  [dirhierarchy setObject:tmpArray forKey:ptc];

  fileEnum = [files objectEnumerator];
  while ((file = [fileEnum nextObject]) != nil)
    {
      [dirmetadata setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%@%@", ptc,file]];
    }
  count = [tmpArray count];
  return count;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
  NSString *ptc = [sender pathToColumn: column];
  NSString *content = [NSString stringWithFormat:@"%@", [[dirhierarchy objectForKey:ptc] objectAtIndex:row]];

  [cell setStringValue:content];
  [cell setTitle:content];
  [cell setLeaf: [[dirmetadata objectForKey:[NSString stringWithFormat:@"%@%@", ptc,content]] boolValue]];
  [cell setLoaded: YES];
}

- (BOOL)browser:(NSBrowser *)browser canDragRowsWithIndexes:(NSIndexSet *)rowIndexes inColumn:(NSInteger)column withEvent:(NSEvent *)event
{
  return YES;
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
  // Doesn't work. Why ????
  printf("windowWillResize: %s\n", [NSStringFromSize(proposedFrameSize) cString]);
  return proposedFrameSize;
}
@end

@implementation CollectionBrowser(Private)
- (void) _refreshView:(id) sender
{
  NSInteger idx;
  NSInteger last = [browser lastColumn];
  directories = [[mpdController getAllDirectories] retain];  
  for (idx = 0;idx < last;idx++)
    {
      [browser reloadColumn:idx];
    }
}
@end
