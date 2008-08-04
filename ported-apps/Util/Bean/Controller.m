#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "ServicesObject.h"

@implementation Controller

//note: application services don't work if the app is not activated unless setServicesProvider is called from
//		Controller (AppDelegate), which is connected in IB (MainMenu : File'sOwner ---> Controller as Delegate)

//perform initialization of Services here (this class must be delegate of NSApp)
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
	[NSApp setServicesProvider: [ServicesObject sharedInstance]];
}

@end
