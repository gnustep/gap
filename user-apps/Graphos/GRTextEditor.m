#import "GRTextEditor.h"

@implementation GRTextEditor

- (id)initEditor:(GRText *)anObject
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
        [self setMaxSize: NSMakeSize(500, 2000)];
        [self setMinSize: NSMakeSize(500, 300)];
        [self setTitle: @"Text Editor"];
        object = anObject;
        myView = nil;
    }
    return self;
}

- (void)setPoint:(NSPoint)p
      withString:(NSString *)string
      attributes:(NSDictionary *)attributes
{
        if (myView == nil)
        {
            myView = [[GRTextEditorView alloc] initWithFrame: [self frame] withString: string attributes: attributes];
            [self setContentView: myView];
        }
        [self center];
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
    if([object locked])
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
