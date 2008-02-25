#import "GRTextEditor.h"

@implementation GRTextEditor

- (id)initEditor:(GRText *)anObject
{
    unsigned int style = NSTitledWindowMask | NSResizableWindowMask;

    self = [super init];

    if(self)
    {
        myWindow = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 500, 300)
                                styleMask: style
                                  backing: NSBackingStoreBuffered
                                    defer: NO];
        isSelect = NO;
        isvalid = NO;
        [myWindow setMaxSize: NSMakeSize(500, 2000)];
        [myWindow setMinSize: NSMakeSize(500, 300)];
        [myWindow setTitle: @"Text Editor"];
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
            myView = [[GRTextEditorView alloc] initWithFrame: [myWindow frame] withString: string attributes: attributes];
            [myWindow setContentView: myView];
        }
        [myWindow center];
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
