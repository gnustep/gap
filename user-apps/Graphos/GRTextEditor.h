#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRText.h"
#import "GRTextEditorView.h"
#import "GRObjectEditor.h"

@interface GRTextEditor : GRObjectEditor
{
    NSWindow *myWindow;
    GRTextEditorView *myView;
    BOOL isSelect;
    BOOL isvalid;
}

- (id)initEditor:(GRText *)anObject;

- (GRTextEditorView *)editorView;

- (void)setPoint:(NSPoint)p
    withString:(NSString *)string
    attributes:(NSDictionary *)attributes;

- (void)select;

- (void)selectAsGroup;

- (BOOL)isSelect;

- (BOOL)isGroupSelected;

- (void)setIsValid:(BOOL)value;

- (BOOL)isValid;

@end
