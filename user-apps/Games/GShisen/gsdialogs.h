#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GSDlogView : NSView
@end

@interface GSUserNameDialog : NSWindow
{
  GSDlogView *dialogView;
  NSTextField *titlefield, *editfield;	
  NSButton *okbutt;
  int result;
}

- (id)initWithTitle:(NSString *)title;
- (int)runModal;
- (NSString *)getEditFieldText;
- (void)buttonAction:(id)sender;


@end

