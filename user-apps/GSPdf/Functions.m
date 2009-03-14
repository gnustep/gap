#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Functions.h"

NSMenuItem *addItemToMenu(NSMenu *menu, NSString *str, 
			  NSString *comm, NSString *sel, NSString *key)
{
  NSMenuItem *item = [menu addItemWithTitle: NSLocalizedString(str, comm)
			   action: NSSelectorFromString(sel) keyEquivalent: key]; 
  return item;
}
