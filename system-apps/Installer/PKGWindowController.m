/* All Rights reserved */

#include <AppKit/NSBox.h>
#include <AppKit/NSDocument.h>
#include <AppKit/NSPopUpButton.h>
#include <AppKit/NSWindow.h>
#include <Foundation/NSString.h>
#include "PKGWindowController.h"

@implementation PKGWindowController


- (id) initWithWindowNibName: (NSString *)name owner: (id)owner
{
  self = [super initWithWindowNibName: name owner: owner];
  if(self != nil)
    {
      infoView = [infoWindow contentView];
      logView = [logWindow contentView];
      progressView = [progressWindow contentView];
    }
  return self;
}


- (void) changeView: (id)sender
{
  int tag = [[sender selectedItem] tag];

  // retain the old content view...
  RETAIN([view contentView]);

  switch(tag)
    {
    case 0:
      [(NSBox *)view setContentView: infoView];
      break;
    case 1:
      [(NSBox *)view setContentView: logView];
      break;
    case 2:
      [(NSBox *)view setContentView: progressView];
      break;
    default:
      break;
    }
}


- (void) deletePackage: (id)sender
{
  /* insert your code here */
  NSLog(@"%@ deletePackage: called",sender);
}


- (void) installPackage: (id)sender
{
  /* insert your code here */
  NSLog(@"%@ installPackage: called",sender);
}


- (void) listPackage: (id)sender
{
  /* insert your code here */
  NSLog(@"%@ listPackage: called",sender);
}

@end
