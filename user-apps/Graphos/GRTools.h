#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GRToolButton : NSButton
{
    int tooltype;
}

- (id)initWithFrame:(NSRect)rect toolType:(int)type;
- (int)tooltype;

@end

@interface GRToolsView : NSView
{
    NSMutableArray *buttons;
    GRToolButton *barrowButt, *warrowButt, *bezierButt, *textButt;
    GRToolButton *circleButt, *rectangleButt, *paintButt, *pencilButt;
    GRToolButton *roteteButt, *reduceButt, *reflectButt, *scissorsButt;
    GRToolButton *handButt, *magnifyButt;
}

- (id)initWithFrame:(NSRect)rect;
- (void)buttonPressed:(id)sender;
- (void)setButtonsPositions:(int)ptype;

@end

@interface GRToolsWindow : NSWindow
{
    GRToolsView *toolsView;
}

- (id)init;
- (void)setButtonsPositions:(int)ptype;

@end
