/* All Rights reserved */

#ifndef __CONTROLLER_H__
#define __CONTROLLER_H__

#include <AppKit/AppKit.h>
#include "mainWindowController.h"
#include "GNUstep.h"

@interface Controller : NSObject
{
  id query;
  id search;
  id index;
  id back;
  id bookshelf;
    
  id textview;
  id tocview;
  id window;
  
  id infoMenu;
  id helpMenu;
  id servicesMenu;
  
  MainWindowController* windowController;
}
- (void) openFile: (id) sender;
- (void) search: (id) sender;
- (void) index: (id) sender;
- (void) back: (id) sender;
- (void) bookshelf: (id) sender;
- (void) print: (id) sender;
- (void) initButtons;
@end

#endif
