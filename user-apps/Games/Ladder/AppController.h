#include <Foundation/Foundation.h>
@interface AppController : NSObject
{
	id prefPanel;
	id playerPanel;
	id playerController;
	id clockController;
	id infoTab;
	id documentInspector;
}
- (id) playerController;
@end
