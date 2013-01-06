/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "MPDController.h"

@interface CollectionBrowser : NSWindowController
{

  IBOutlet NSBrowser *browser;
  IBOutlet NSBrowser *window;

  MPDController *mpdController;
  NSArray *directories;
  NSMutableDictionary *dirhierarchy;
  NSMutableDictionary *dirmetadata;  
}

// Initialization Methods
+ (id) sharedCollectionBrowser;

@end
