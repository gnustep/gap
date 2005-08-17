//
//  GRTextEditorView.h
//  Draw
//
//  Created by Riccardo Mottola on Fri Aug 05 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GRTextEditorView : NSView
{
    NSView *controlsView;
    NSScrollView *scrollView;
    NSPopUpButton *fontsPopUp;
    NSTextField *sizeField;
    NSText *theText;
    NSButton *leftButt, *centerButt, *rightButt, *cancelButt, *okButt;
    int result;

    NSTextAlignment textAlignment;
    NSFont *font;
    int fontSize;
    float parSpace;
}

- (id)initWithFrame:(NSRect)frameRect
         withString:(NSString *)string
         attributes:(NSDictionary *)attributes;

- (int)runModal;

- (void)makeFontsPopUp:(NSString *)selFontName;

- (void)changeTextAlignment:(id)sender;

- (void)changeTextFont:(id)sender;

- (void)sizeFieldDidEndEditing:(NSNotification *)notification;

- (void)okCancelPressed:(id)sender;

- (NSString *)textString;

- (NSDictionary *)textAttributes;

@end
