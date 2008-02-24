#import "GRTextEditor.h"

@implementation GRTextEditor

- (id)initAtPoint:(NSPoint)p
       withString:(NSString *)string
         withText:(GRText *)aText
       attributes:(NSDictionary *)attributes
{
    unsigned int style = NSTitledWindowMask | NSResizableWindowMask;

    self = [super initWithContentRect: NSMakeRect(0, 0, 500, 300)
                            styleMask: style
                              backing: NSBackingStoreBuffered
                                defer: NO];
    if(self)
    {
        isSelect = NO;
        isvalid = NO;
        object = aText;
        [self setMaxSize: NSMakeSize(500, 2000)];
        [self setMinSize: NSMakeSize(500, 300)];
        [self setTitle: @"Text Editor"];
        myView = [[GRTextEditorView alloc] initWithFrame: [self frame] withString: string attributes: attributes];
        [self setContentView: myView];
        [self center];
    }
    return self;
}

- (void)dealloc
{
    [myView release];
    [super dealloc];
}

- (GRTextEditorView *)editorView
{
    return myView;
}

- (void)select
{
    [self selectAsGroup];
}

- (void)selectAsGroup
{
    if([object isLocked])
        return;
    isSelect = YES;
}

- (void)unselect
{
    isSelect = NO;
}

- (BOOL)isSelect
{
    return isSelect;
}

- (BOOL)isGroupSelected
{
    return isSelect;
}

- (void)setIsValid:(BOOL)value
{
    isvalid = value;
}

- (BOOL)isValid
{
    return isvalid;
}

@end
