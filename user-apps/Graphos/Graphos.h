#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRTools.h"

typedef enum {
    blackarrowtool,
    whitearrowtool,
    beziertool,
    texttool,
    circletool,
    rectangletool,
    painttool,
    penciltool,
    rotatetool,
    reducetool,
    reflecttool,
    scissorstool,
    handtool,
    magnifytool
} ToolType;

@interface Graphos : NSObject
{
    GRToolsWindow *tools;
    ToolType tooltype;
    NSDictionary *pfbPathForFont;
}

- (void)setToolType:(ToolType)type;

- (ToolType)currentToolType;

- (void)updateCurrentWindow;


@end

