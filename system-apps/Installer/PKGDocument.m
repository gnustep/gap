/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "PKGDocument.h"
#include "PKGWindowController.h"

@implementation PKGDocument

- (void) makeWindowControllers
{
  windowController = [[PKGWindowController alloc] initWithWindowNibName: @"PackageWindow"];
  [self addWindowController: windowController];
}

- (BOOL) loadDataRepresentation: (NSData *)data ofType: (NSString *)type
{
  return YES;
}

@end
