/*
 Project: Graphos
 GRTextEditorView.m

 Copyright (C) 2000-2008 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */



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
    int i;
    
    // these just because we do it programmatically at the moment
    NSFontManager *fontMgr;
    NSArray *fontList;

    fontMgr = [NSFontManager sharedFontManager];
    fontList = [fontMgr availableFonts];

    [fontsPopUp removeAllItems];
    for(i = 0; i < [fontList count]; i++)
    	[fontsPopUp addItemWithTitle: [fontList objectAtIndex: i]];

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
            if (font != nil)
            {
              [theText setFont: font];
              [theText setNeedsDisplay: YES];
            }
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

    style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [style setAlignment: textAlignment];
    [style setParagraphSpacing: parSpace];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [theText font], NSFontAttributeName,
        style, NSParagraphStyleAttributeName, nil];
    return dict;
}

@end

