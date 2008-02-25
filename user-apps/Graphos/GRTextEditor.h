#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "GRText.h"
#import "GRTextEditorView.h"

@interface GRTextEditor : NSWindow
{
    GRTextEditorView *myView;
    GRText *object;
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

- (void)unselect;

- (BOOL)isSelect;

- (BOOL)isGroupSelected;

- (void)setIsValid:(BOOL)value;

- (BOOL)isValid;

@end
