/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "CollectionBrowser.h"
#include "Strings.h"

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
  NSIndexPath *indexPath = [browser selectionIndexPath];
  NSCell *selectedSong;
  NSString *path = [browser pathToColumn:[browser selectedColumn]];
NSLog(@"the selected cells: %@", [browser selectedCells]); 
NSLog(@"the index path: %@, the path: %@", indexPath, path);
  while ((selectedSong = [songEnum nextObject]) != nil)
    {
NSLog(@"the selected song: %@",
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
                selector: @selector(updateCollection:)
                    name: ShownCollectionChangedNotification
                  object: nil];

  [browser setPath:@"/"];
  [browser setDelegate: self];
  [browser setDoubleAction: @selector(browserDoubleClick:)];

 //[self _refreshViews];
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

- (IBAction) browserDoubleClick: (id) sender
{
  NSInteger column = [browser selectedColumn];
  NSInteger row = [browser selectedRowInColumn: column];
    
  //[mpdController getAllFilesInDirectory];
NSLog(@"got this double clicked: %@", [browser selectionIndexPath]);

    // then dig into your data structure with the row and column

} // browserDoubleClick

- (void)windowDidResize:(NSNotification *)aNotification
{
  NSRect rect = [[self window] frame];

  rect.origin.x = rect.origin.y = 10;
  rect.size.width -= 20;
  rect.size.height -= 150;

  [browser setFrame: rect];
  [browser sizeToFit];
  [[[self window] contentView] setNeedsDisplay: YES];
}

- (BOOL)browser:(NSBrowser *)browser canDragRowsWithIndexes:(NSIndexSet *)rowIndexes inColumn:(NSInteger)column withEvent:(NSEvent *)event
{
  return YES;
}

- (void)doDoubleClick:(id)sender
{
  NSLog(@"do double click");
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
  // Doesn't work. Why ????
  printf("windowWillResize: %s\n", [NSStringFromSize(proposedFrameSize) cString]);
  return proposedFrameSize;
}

@end
