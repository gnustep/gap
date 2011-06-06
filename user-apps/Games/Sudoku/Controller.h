#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "SudokuView.h"

typedef enum {
  MENU_NEW_20CLUES = 20,
  MENU_NEW_25CLUES = 25,
  MENU_NEW_30CLUES = 30,
  MENU_NEW_35CLUES = 35,
  MENU_NEW_48CLUES = 48,
  MENU_NEW_60CLUES = 60,
  MENU_NEW_70CLUES = 70,
} MENU_NEW;

@interface Controller: NSObject
{
    NSPanel *palette;
    NSPanel *enterPanel;
    SudokuView *sdkview;
}

- makeInputPanel;

- newPuzzle:(id)sender;

- actionEnter:(id)sender;
- actionReset:(id)sender;
- actionCancel:(id)sender;

- enterPuzzle:(id)sender;

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- makeDigitPalette;

@end

