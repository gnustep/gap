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

- (id)initAtPoint:(NSPoint)p
       withString:(NSString *)string
       attributes:(NSDictionary *)attributes;

- (GRTextEditorView *)editorView;

- (void)select;

- (void)selectAsGroup;

- (void)unselect;

- (BOOL)isSelect;

- (BOOL)isGroupSelected;

- (void)setIsValid:(BOOL)value;

- (BOOL)isValid;

@end
