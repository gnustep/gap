/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "MPDController.h"

@interface LyricsInspector : NSWindowController <NSXMLParserDelegate>
{
  id artist;
  id lyricsText;
  id title;

  MPDController *mpdController;
  NSMutableString *element;
  NSMutableString *lyricsURL;
}
+ (id) sharedLyricsInspector;

- (void) openURL: (id)sender;
@end
