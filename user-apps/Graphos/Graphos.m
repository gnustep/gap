#import "Graphos.h"
#import "GRFunctions.h"

@implementation Graphos

- (void)dealloc
{
    [tools release];
    [pfbPathForFont release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Graphos: applicationDidFinishLaunching");
    tools = [[GRToolsWindow alloc] init];
    [tools display];
    [tools orderFront:nil];
}

- (void)setToolType:(ToolType)type
{
    tooltype = type;
    [tools setButtonsPositions: tooltype];
}

- (ToolType)currentToolType
{
    return tooltype;
}

// FIXME This is pretty ugly. GRText is the only thing that uses
// it. maybe its possible to get rid of it.
- (void)updateCurrentWindow
{
    NSWindow *curWin = [[[[[NSDocumentController sharedDocumentController] currentDocument] windowControllers] objectAtIndex: 0] window];
    [curWin display];
}



@end














