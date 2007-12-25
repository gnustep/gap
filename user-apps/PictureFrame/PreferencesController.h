/* PreferencesController 

*/

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSObject
{
    IBOutlet id tabView;    
    NSFont *font;
}

+ sharedPreferences;

- (IBAction) showPreferences: (id)sender;
- (IBAction) loadValues: (id)sender;
- (IBAction) setValue: (id)sender;
- (void) changeFont: (id)sender;
- (void) addPreferenceController: (id)controller;

@end

extern NSString *DFullScreen;
extern NSString *DStartTime;
extern NSString *DStopTime;
extern NSString *DPhotoPath;
extern NSString *DAlbum;
extern NSString *DKeyword;
extern NSString *DSpeed;
extern NSString *DShowOverlay;
extern NSString *DOverlayInfo;
extern NSString *DFontName;

extern NSString *DTransition;
extern NSString *DTransitionTime;

enum {
  INFO_NONE = 0,
  INFO_CLK1 = 1,
  INFO_CLK2 = 2,
  INFO_WEATHER = 4,
  INFO_PHOTO = 8
};
#define MAX_INFO 15
#define MAX_CLK  3

extern NSString *DOffKey;
extern NSString *DInfoKey;
extern NSString *DBackKey;
extern NSString *DSpeedDownKey;
extern NSString *DSpeedUpKey;
extern NSString *DToggleScreenKey;
