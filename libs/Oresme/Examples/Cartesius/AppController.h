/* 
   Project: Cartesius

   Author: Riccardo Mottola

   Created: 2011-08-23 01:18:46 +0200 by multix
   
   Application Controller
*/
 

#import <AppKit/AppKit.h>

@class OKCartesius;

@interface AppController : NSObject
{
  IBOutlet OKCartesius *cartesiusView;
}

+ (void)  initialize;

- (id) init;
- (void) dealloc;

- (void) awakeFromNib;

- (void) applicationDidFinishLaunching: (NSNotification *)aNotif;
- (BOOL) applicationShouldTerminate: (id)sender;
- (void) applicationWillTerminate: (NSNotification *)aNotif;
- (BOOL) application: (NSApplication *)application
	    openFile: (NSString *)fileName;

- (void) showPrefPanel: (id)sender;

@end

