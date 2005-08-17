#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "GRTextEditorView.h"

@interface GRTextEditor : NSWindow
{
    GRTextEditorView *myView;
}

- (id)initAtPoint:(NSPoint)p
       withString:(NSString *)string
       attributes:(NSDictionary *)attributes;

- (GRTextEditorView *)editorView;

@end
