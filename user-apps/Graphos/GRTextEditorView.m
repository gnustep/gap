//
//  GRTextEditorView.m
//  Draw
//
//  Created by Riccardo Mottola on Fri Aug 05 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import "GRTextEditorView.h"

@implementation GRTextEditorView

- (id)initWithFrame:(NSRect)frameRect
         withString:(NSString *)string
         attributes:(NSDictionary *)attributes
{
    NSString *firstStr;
    NSFont *f;
    NSString *fname = nil;
    NSParagraphStyle *pstyle;

    self = [super initWithFrame: frameRect];
    if(self)
    {
        controlsView = [[NSView alloc] initWithFrame: NSMakeRect(0, 260, 500, 40)];
        [controlsView setAutoresizingMask: ~NSViewMaxYMargin & ~NSViewHeightSizable];

        fontsPopUp = [[NSPopUpButton alloc] initWithFrame: NSMakeRect(10, 10, 160, 20) pullsDown: NO];
        [fontsPopUp setBordered: YES];
        [fontsPopUp setTarget: self];
        [fontsPopUp setAction:@selector(changeTextFont:)];
        [controlsView addSubview: fontsPopUp];

        sizeField = [[NSTextField alloc] initWithFrame: NSMakeRect(181, 10, 28, 20)];
        [sizeField setAlignment: NSRightTextAlignment];
        [controlsView addSubview: sizeField];

        leftButt = [[NSButton alloc] initWithFrame: NSMakeRect(220, 10, 20, 20)];
        [leftButt setButtonType: NSOnOffButton];
        [leftButt setImage: [NSImage imageNamed:@"txtAlignLeft.tiff"]];
        [leftButt setImagePosition: NSImageOnly];
        [leftButt setTarget: self];
        [leftButt setAction: @selector(changeTextAlignment:)];
        [controlsView addSubview: leftButt];

        centerButt = [[NSButton alloc] initWithFrame: NSMakeRect(250, 10, 20, 20)];
        [centerButt setButtonType: NSOnOffButton];
        [centerButt setImage: [NSImage imageNamed:@"txtAlignCenter.tiff"]];
        [centerButt setImagePosition: NSImageOnly];
        [centerButt setTarget: self];
        [centerButt setAction: @selector(changeTextAlignment:)];
        [controlsView addSubview: centerButt];

        rightButt = [[NSButton alloc] initWithFrame: NSMakeRect(280, 10, 20, 20)];
        [rightButt setButtonType: NSOnOffButton];
        [rightButt setImage: [NSImage imageNamed:@"txtAlignRight.tiff"]];
        [rightButt setImagePosition: NSImageOnly];
        [rightButt setTarget: self];
        [rightButt setAction: @selector(changeTextAlignment:)];
        [controlsView addSubview: rightButt];

        cancelButt = [[NSButton alloc] initWithFrame: NSMakeRect(360, 5, 60, 30)];
        [cancelButt setButtonType: NSMomentaryLight];
        [cancelButt setTitle: @"Cancel"];
        [cancelButt setTarget: self];
        [cancelButt setAction: @selector(okCancelPressed:)];
        [controlsView addSubview: cancelButt];

        okButt = [[NSButton alloc] initWithFrame: NSMakeRect(430, 5, 60, 30)];
        [okButt setButtonType: NSMomentaryLight];
        [okButt setTitle: @"Ok"];
        [okButt setTarget: self];
        [okButt setAction: @selector(okCancelPressed:)];
        [controlsView addSubview: okButt];

        if(attributes) {
            firstStr = [NSString stringWithString: string];
            f = [attributes objectForKey: NSFontAttributeName];
            fname = [f fontName];
            fontSize = (int)[f pointSize];
            pstyle = [attributes objectForKey: NSParagraphStyleAttributeName];
            parSpace = [pstyle paragraphSpacing];
            textAlignment = [pstyle alignment];
            if(textAlignment == NSLeftTextAlignment)
                [leftButt setState: NSOnState];
            if(textAlignment == NSCenterTextAlignment)
                [centerButt setState: NSOnState];
            if(textAlignment == NSRightTextAlignment)
                [rightButt setState: NSOnState];

        } else {
            firstStr = [NSString stringWithString: @"New Text"];
            textAlignment = NSLeftTextAlignment;
            [leftButt setState: NSOnState];
            fontSize = 12;
            parSpace = fontSize * 1.2;
        }

        [sizeField setStringValue: [NSString stringWithFormat:@"%i", fontSize]];

        [self addSubview: controlsView];

        scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 500, 260)];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setAutoresizingMask: NSViewHeightSizable];

        theText = [[NSText alloc] initWithFrame: NSMakeRect(20, 0, 480, 250)];
        [theText setAlignment: textAlignment];
        [theText setString: firstStr];
        [self makeFontsPopUp: fname];

        [scrollView setDocumentView: theText];

        [self addSubview: scrollView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sizeFieldDidEndEditing:)
                                                     name:@"NSControlTextDidEndEditingNotification" object:nil];
    }
    return self;
}

- (void) dealloc
{
    [leftButt release];
    [centerButt release];
    [rightButt release];
    [cancelButt release];
    [okButt release];
    [sizeField release];
    [fontsPopUp release];
    [controlsView release];
    [theText release];
    [scrollView release];
    [super dealloc];
}

- (int)runModal
{
    NSApplication *app = [NSApplication sharedApplication];
    [app runModalForWindow: [self window]];
    return result;
}

- (void)makeFontsPopUp:(NSString *)selFontName
{
    NSDictionary *env;
    NSMutableDictionary *fontsDict;
    NSArray *fontsList;
    NSString *sysFontsListPath, *usrFontsListPath;
    BOOL fileExists;
    int i;

    fontsDict = [NSMutableDictionary dictionaryWithCapacity: 1];
    env = [[NSProcessInfo processInfo] environment];

    sysFontsListPath = [NSString stringWithFormat:
        @"%@/Libraries/Resources/GNUstepSystemXFontList",
        [env objectForKey: @"GNUSTEP_SYSTEM_ROOT"]];

    usrFontsListPath = [NSString stringWithFormat:
        @"%@/GNUstep/.GNUstepXFontList", NSHomeDirectory()];

    fileExists  = [[NSFileManager defaultManager] fileExistsAtPath: sysFontsListPath];

    if(fileExists) {
        [fontsDict addEntriesFromDictionary: [NSMutableDictionary
                                                dictionaryWithContentsOfFile: sysFontsListPath]];
    }

    fileExists  = [[NSFileManager defaultManager] fileExistsAtPath: usrFontsListPath];

    if(fileExists) {
        [fontsDict addEntriesFromDictionary: [NSMutableDictionary
                                                dictionaryWithContentsOfFile: usrFontsListPath]];
    }

    if([fontsDict count] > 0) {
        [fontsPopUp removeAllItems];
        fontsList = [NSArray arrayWithArray: [fontsDict allKeys]];
        for(i = 0; i < [fontsDict count]; i++)
            if(i < 30)
                [fontsPopUp addItemWithTitle: [fontsList objectAtIndex: i]];
    }

    if(selFontName)
        [fontsPopUp selectItemWithTitle: selFontName];

    font = [NSFont fontWithName: [fontsPopUp titleOfSelectedItem] size: fontSize];
    [theText setFont: font];
    [theText setNeedsDisplay: YES];
}

- (void)changeTextAlignment:(id)sender
{
    NSButton *b = (NSButton *)sender;
    if(b == leftButt) {
        textAlignment = NSLeftTextAlignment;
        [leftButt setState: NSOnState];
        [centerButt setState: NSOffState];
        [rightButt setState: NSOffState];
    } else if(b == centerButt) {
        textAlignment = NSCenterTextAlignment;
        [leftButt setState: NSOffState];
        [centerButt setState: NSOnState];
        [rightButt setState: NSOffState];
    } else if(b == rightButt) {
        textAlignment = NSRightTextAlignment;
        [leftButt setState: NSOffState];
        [centerButt setState: NSOffState];
        [rightButt setState: NSOnState];
    }

    [theText setAlignment: textAlignment];
    [theText setNeedsDisplay: YES];
}

- (void)changeTextFont:(id)sender
{
    NSString *selFontName = [sender titleOfSelectedItem];
    font = [NSFont fontWithName: selFontName size: fontSize];
    parSpace = fontSize * 1.2;
    [theText setFont: font];
    [theText setNeedsDisplay: YES];
}

- (void)sizeFieldDidEndEditing:(NSNotification *)aNotification
{
    int fsz;
    NSString *selFontName;

    if((NSTextField *)[aNotification object] == sizeField) {
        fsz = [sizeField intValue];
        if(fsz && fsz != fontSize) {
            fontSize = fsz;
            parSpace = fontSize * 1.2;
            selFontName = [fontsPopUp titleOfSelectedItem];
            font = [NSFont fontWithName: selFontName size: fontSize];
            [theText setFont: font];
            [theText setNeedsDisplay: YES];
        }
    }
}

- (void)okCancelPressed:(id)sender
{
    if(sender == okButt)
        result = NSAlertDefaultReturn;
    else
        result = NSAlertAlternateReturn;
    [[self window] orderOut: self];
    [[NSApplication sharedApplication] stopModal];
}

- (NSString *)textString
{
    return [theText string];
}

- (NSDictionary *)textAttributes
{
    NSDictionary *dict;
    NSMutableParagraphStyle *style;

    // there must be a problem with GNUstep's implementation of this
    // or the compiler is just overly picky
    style = (NSMutableParagraphStyle *)[NSMutableParagraphStyle defaultParagraphStyle];
    [style setAlignment: textAlignment];
    [style setParagraphSpacing: parSpace];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [theText font], NSFontAttributeName,
        style, NSParagraphStyleAttributeName, nil];
    return dict;
}

@end

