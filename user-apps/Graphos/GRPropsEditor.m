/*
 Project: Graphos
 GRPropsEditor.m

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

#import "GRPropsEditor.h"
#import "GRDocView.h"

@implementation GRPropsEditor

- (id)initWithFrame:(NSRect)frameRect
         forDocView:(GRDocView *)aView
   objectProperties:(NSDictionary *)objprops
{
    NSString *type;

    NSLog(@"prop editor inited");
    self = [super initWithFrame: frameRect];
    if(self) {
        docview = aView;
        ispath = NO;
        type = [objprops objectForKey: @"type"];
        if([type isEqualToString: @"path"])
            ispath = YES;

        if(ispath)
        {
            flatness = [[objprops objectForKey: @"flatness"] floatValue];
            linejoin = [[objprops objectForKey: @"linejoin"] intValue];
            linecap = [[objprops objectForKey: @"linecap"] intValue];
            miterlimit = [[objprops objectForKey: @"miterlimit"] floatValue];
            linewidth = [[objprops objectForKey: @"linewidth"] floatValue];
        } else
        {
            flatness = miterlimit = linewidth = 0.0;
            linejoin = linecap = 0;
        }

        filled = (BOOL)[[objprops objectForKey: @"filled"] intValue];
        fillcyan = [[objprops objectForKey: @"fillcyan"] floatValue];
        fillmagenta = [[objprops objectForKey: @"fillmagenta"] floatValue];
        fillyellow = [[objprops objectForKey: @"fillyellow"] floatValue];
        fillblack = [[objprops objectForKey: @"fillblack"] floatValue];
        fillalpha = [[objprops objectForKey: @"fillalpha"] floatValue];

        stroked = (BOOL)[[objprops objectForKey: @"stroked"] intValue];
        strokecyan = [[objprops objectForKey: @"strokecyan"] floatValue];
        strokemagenta = [[objprops objectForKey: @"strokemagenta"] floatValue];
        strokeyellow = [[objprops objectForKey: @"strokeyellow"] floatValue];
        strokeblack = [[objprops objectForKey: @"strokeblack"] floatValue];
        strokealpha = [[objprops objectForKey: @"strokealpha"] floatValue];


        // ----------------------- FILL ------------------------
        fllLabel = [[[NSTextField alloc] init] autorelease];
        [fllLabel setFrame: NSMakeRect(35, 275, 40, 20)];
        [fllLabel setBezeled:NO];
        [fllLabel setEditable:NO];
        [fllLabel setSelectable:NO];
        [fllLabel setStringValue: @"filled"];
        [fllLabel setDrawsBackground:NO];
        [self addSubview: fllLabel];

        fllCyanField = [[[NSTextField alloc] init] autorelease];
        [fllCyanField setFrame: NSMakeRect(80, 250, 40, 20)];
        [self addSubview: fllCyanField];
        fllCyanLabel = [[[NSTextField alloc] init] autorelease];
        [fllCyanLabel setFrame: NSMakeRect(125, 250, 60, 20)];
        [fllCyanLabel setDrawsBackground:NO];
        [fllCyanLabel setBezeled:NO];
        [fllCyanLabel setEditable:NO];
        [fllCyanLabel setSelectable:NO];
        [fllCyanLabel setStringValue: @"cyan"];
        [self addSubview: fllCyanLabel];

        fllMagentaField = [[[NSTextField alloc] init] autorelease];
        [fllMagentaField setFrame: NSMakeRect(80, 220, 40, 20)];
        [self addSubview: fllMagentaField];
        fllMagentaLabel = [[[NSTextField alloc] init] autorelease];
        [fllMagentaLabel setFrame: NSMakeRect(125, 220, 60, 20)];
        [fllMagentaLabel setDrawsBackground:NO];
        [fllMagentaLabel setBezeled:NO];
        [fllMagentaLabel setEditable:NO];
        [fllMagentaLabel setSelectable:NO];
        [fllMagentaLabel setStringValue: @"magenta"];
        [self addSubview: fllMagentaLabel];

        fllYellowField = [[[NSTextField alloc] init] autorelease];
        [fllYellowField setFrame: NSMakeRect(80, 190, 40, 20)];
        [self addSubview: fllYellowField];
        fllYellowLabel = [[[NSTextField alloc] init] autorelease];
        [fllYellowLabel setFrame: NSMakeRect(125, 190, 60, 20)];
        [fllYellowLabel setDrawsBackground:NO];
        [fllYellowLabel setBezeled:NO];
        [fllYellowLabel setEditable:NO];
        [fllYellowLabel setSelectable:NO];
        [fllYellowLabel setStringValue: @"yellow"];
        [self addSubview: fllYellowLabel];

        fllBlakField = [[[NSTextField alloc] init] autorelease];
        [fllBlakField setFrame: NSMakeRect(80, 160, 40, 20)];
        [self addSubview: fllBlakField];
        fllBlakLabel = [[[NSTextField alloc] init] autorelease];
        [fllBlakLabel setFrame: NSMakeRect(125, 160, 60, 20)];
        [fllBlakLabel setDrawsBackground:NO];
        [fllBlakLabel setBezeled:NO];
        [fllBlakLabel setEditable:NO];
        [fllBlakLabel setSelectable:NO];
        [fllBlakLabel setStringValue: @"black"];
        [self addSubview: fllBlakLabel];

        fllButt = [[[NSButton alloc] init] autorelease];
        [fllButt setFrame: NSMakeRect(10, 275, 20, 20)];
        [fllButt setButtonType: NSSwitchButton];
        [fllButt setBordered: NO];
        [fllButt setTitle: @""];
        [fllButt setTarget: self];
        [fllButt setAction: @selector(fllButtPressed:)];
        if(filled)
            [fllButt setState: NSOnState];
        [self addSubview: fllButt];
        [self fllButtPressed: fllButt];


        // ---------------------- STROKE -----------------------
        stkLabel = [[[NSTextField alloc] init] autorelease];
        [stkLabel setFrame: NSMakeRect(210, 275, 40, 20)];
        [stkLabel setDrawsBackground:NO];
        [stkLabel setBezeled:NO];
        [stkLabel setEditable:NO];
        [stkLabel setSelectable:NO];
        [stkLabel setStringValue: @"stroked"];
        [self addSubview: stkLabel];

        stkCyanField = [[[NSTextField alloc] init] autorelease];
        [stkCyanField setFrame: NSMakeRect(255, 250, 40, 20)];
        [self addSubview: stkCyanField];
        stkCyanLabel = [[[NSTextField alloc] init] autorelease];
        [stkCyanLabel setFrame: NSMakeRect(300, 250, 60, 20)];
        [stkCyanLabel setDrawsBackground:NO];
        [stkCyanLabel setBezeled:NO];
        [stkCyanLabel setEditable:NO];
        [stkCyanLabel setSelectable:NO];
        [stkCyanLabel setStringValue: @"cyan"];
        [self addSubview: stkCyanLabel];

        stkMagentaField = [[[NSTextField alloc] init] autorelease];
        [stkMagentaField setFrame: NSMakeRect(255, 220, 40, 20)];
        [self addSubview: stkMagentaField];
        stkMagentaLabel = [[[NSTextField alloc] init] autorelease];
        [stkMagentaLabel setFrame: NSMakeRect(300, 220, 60, 20)];
        [stkMagentaLabel setDrawsBackground:NO];
        [stkMagentaLabel setBezeled:NO];
        [stkMagentaLabel setEditable:NO];
        [stkMagentaLabel setSelectable:NO];
        [stkMagentaLabel setStringValue: @"magenta"];
        [self addSubview: stkMagentaLabel];

        stkYellowField = [[[NSTextField alloc] init] autorelease];
        [stkYellowField setFrame: NSMakeRect(255, 190, 40, 20)];
        [self addSubview: stkYellowField];
        stkYellowLabel = [[[NSTextField alloc] init] autorelease];
        [stkYellowLabel setFrame: NSMakeRect(300, 190, 60, 20)];
        [stkYellowLabel setDrawsBackground:NO];
        [stkYellowLabel setBezeled:NO];
        [stkYellowLabel setEditable:NO];
        [stkYellowLabel setSelectable:NO];
        [stkYellowLabel setStringValue: @"yellow"];
        [self addSubview: stkYellowLabel];

        stkBlakField = [[[NSTextField alloc] init] autorelease];
        [stkBlakField setFrame: NSMakeRect(255, 160, 40, 20)];
        [self addSubview: stkBlakField];
        stkBlakLabel = [[[NSTextField alloc] init] autorelease];
        [stkBlakLabel setFrame: NSMakeRect(300, 160, 60, 20)];
        [stkBlakLabel setDrawsBackground:NO];
        [stkBlakLabel setBezeled:NO];
        [stkBlakLabel setEditable:NO];
        [stkBlakLabel setSelectable:NO];
        [stkBlakLabel setStringValue: @"black"];
        [self addSubview: stkBlakLabel];

        stkButt = [[[NSButton alloc] init] autorelease];
        [stkButt setFrame: NSMakeRect(185, 275, 20, 20)];
        [stkButt setButtonType: NSSwitchButton];
        [stkButt setBordered: NO];
        [stkButt setTitle: @""];
        [stkButt setTarget: self];
        [stkButt setAction: @selector(stkButtPressed:)];
        if(stroked)
            [stkButt setState: NSOnState];
        [self addSubview: stkButt];
        [self stkButtPressed: stkButt];


        // ---------------------- LINE CAP ----------------------
        lineCapLabel = [[[NSTextField alloc] init] autorelease];
        [lineCapLabel setFrame: NSMakeRect(380, 275, 80, 20)];
        [lineCapLabel setDrawsBackground:NO];
        [lineCapLabel setBezeled:NO];
        [lineCapLabel setEditable:NO];
        [lineCapLabel setSelectable:NO];
        [lineCapLabel setStringValue: @"line cap"];
        [self addSubview: lineCapLabel];

        buttonCell = [[NSButtonCell new] autorelease];
        [buttonCell setButtonType: NSRadioButton];
        [buttonCell setBordered: NO];
        [buttonCell setTitle: @""];

        lineCapMatrix = [[[NSMatrix alloc] initWithFrame: NSMakeRect(380, 215, 20, 60)
                                                    mode: NSRadioModeMatrix prototype: buttonCell
                                            numberOfRows: 3 numberOfColumns: 1] autorelease];
        [lineCapMatrix setCellSize: NSMakeSize(20, 20)];
        [lineCapMatrix setIntercellSpacing: NSZeroSize];
        [[lineCapMatrix cellAtRow: 0 column: 0] setTag: 0];
        [[lineCapMatrix cellAtRow: 1 column: 0] setTag: 1];
        [[lineCapMatrix cellAtRow: 2 column: 0] setTag: 2];
        if(linecap == 0)
            [[lineCapMatrix cellAtRow: 0 column: 0] setState: NSOnState];
        if(linecap == 1)
            [[lineCapMatrix cellAtRow: 1 column: 0] setState: NSOnState];
        if(linecap == 2)
            [[lineCapMatrix cellAtRow: 2 column: 0] setState: NSOnState];
        [lineCapMatrix setTarget: self];
        [lineCapMatrix setAction: @selector(setLnCap:)];
        [self addSubview: lineCapMatrix];


        // ---------------------- LINE JOIN ----------------------
        lineJoinLabel = [[[NSTextField alloc] init] autorelease];
        [lineJoinLabel setFrame: NSMakeRect(380, 190, 80, 20)];
        [lineJoinLabel setDrawsBackground:NO];
        [lineJoinLabel setBezeled:NO];
        [lineJoinLabel setEditable:NO];
        [lineJoinLabel setSelectable:NO];
        [lineJoinLabel setStringValue: @"line join"];
        [self addSubview: lineJoinLabel];

        lineJoinMatrix = [[[NSMatrix alloc] initWithFrame: NSMakeRect(380, 100, 20, 81)
                                                     mode: NSRadioModeMatrix prototype: buttonCell
                                             numberOfRows: 3 numberOfColumns: 1] autorelease];
        [lineJoinMatrix setCellSize: NSMakeSize(20, 30)];
        [lineJoinMatrix setIntercellSpacing: NSZeroSize];
        [[lineJoinMatrix cellAtRow: 0 column: 0] setTag: 0];
        [[lineJoinMatrix cellAtRow: 1 column: 0] setTag: 1];
        [[lineJoinMatrix cellAtRow: 2 column: 0] setTag: 2];
        if(linejoin == 0)
            [[lineJoinMatrix cellAtRow: 0 column: 0] setState: NSOnState];
        if(linejoin == 1)
            [[lineJoinMatrix cellAtRow: 1 column: 0] setState: NSOnState];
        if(linejoin == 2)
            [[lineJoinMatrix cellAtRow: 2 column: 0] setState: NSOnState];
        [lineJoinMatrix setTarget: self];
        [lineJoinMatrix setAction: @selector(setLnJoin:)];
        [self addSubview: lineJoinMatrix];


        // ---------------------- FLATNESS ----------------------
        flatnessField = [[[NSTextField alloc] init] autorelease];
        [flatnessField setFrame: NSMakeRect(10, 120, 40, 20)];
        [flatnessField setStringValue:
            [NSString stringWithFormat:@"%.2f", flatness]];
        [self addSubview: flatnessField];
        flatnessLabel = [[[NSTextField alloc] init] autorelease];
        [flatnessLabel setFrame: NSMakeRect(55, 120, 60, 20)];
        [flatnessLabel setDrawsBackground:NO];
        [flatnessLabel setBezeled:NO];
        [flatnessLabel setEditable:NO];
        [flatnessLabel setSelectable:NO];
        [flatnessLabel setStringValue: @"flatness"];
        [self addSubview: flatnessLabel];


        // -------------------- MITER LIMIT --------------------
        miterlimitField = [[[NSTextField alloc] init] autorelease];
        [miterlimitField setFrame: NSMakeRect(130, 120, 40, 20)];
        [miterlimitField setStringValue:
            [NSString stringWithFormat:@"%.2f", miterlimit]];
        [self addSubview: miterlimitField];
        miterlimitLabel = [[[NSTextField alloc] init] autorelease];
        [miterlimitLabel setFrame: NSMakeRect(175, 120, 60, 20)];
        [miterlimitLabel setDrawsBackground:NO];
        [miterlimitLabel setBezeled:NO];
        [miterlimitLabel setEditable:NO];
        [miterlimitLabel setSelectable:NO];
        [miterlimitLabel setStringValue: @"miter limit"];
        [self addSubview: miterlimitLabel];


        // -------------------- LINE WIDTH --------------------
        linewidthField = [[[NSTextField alloc] init] autorelease];
        [linewidthField setFrame: NSMakeRect(250, 120, 40, 20)];
        [linewidthField setStringValue:
            [NSString stringWithFormat:@"%.2f", linewidth]];
        [self addSubview: linewidthField];
        linewidthLabel = [[[NSTextField alloc] init] autorelease];
        [linewidthLabel setFrame: NSMakeRect(295, 120, 60, 20)];
        [linewidthLabel setDrawsBackground:NO];
        [linewidthLabel setBezeled:NO];
        [linewidthLabel setEditable:NO];
        [linewidthLabel setSelectable:NO];
        [linewidthLabel setStringValue: @"line width"];
        [self addSubview: linewidthLabel];


        // -------------------- OK & CANCEL --------------------
        cancelButt = [[NSButton alloc] initWithFrame: NSMakeRect(360, 10, 60, 30)];
        [cancelButt setButtonType: NSMomentaryLight];
        [cancelButt setTitle: @"Cancel"];
        [cancelButt setTarget: self];
        [cancelButt setAction: @selector(okCancelPressed:)];
        [self addSubview: cancelButt];

        okButt = [[NSButton alloc] initWithFrame: NSMakeRect(430, 10, 60, 30)];
        [okButt setButtonType: NSMomentaryLight];
        [okButt setTitle: @"Ok"];
        [okButt setTarget: self];
        [okButt setAction: @selector(okCancelPressed:)];
        [self addSubview: okButt];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidEndEditing:)
                                                     name:@"NSControlTextDidEndEditingNotification" object:nil];
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (int)runModal
{
    NSApplication *app = [NSApplication sharedApplication];
    [app runModalForWindow: [self window]];
    return result;
}

- (void)textFieldDidEndEditing:(NSNotification *)aNotification
{
    NSTextField *field = (NSTextField *)[aNotification object];

    if(field == flatnessField)
        flatness = [flatnessField floatValue];
    else if(field == miterlimitField)
        miterlimit = [miterlimitField floatValue];
    else if(field == linewidthField)
        linewidth = [linewidthField floatValue];
    else if(field == fllCyanField)
        fillcyan = [fllCyanField floatValue] / 100;
    else if(field == fllMagentaField)
        fillmagenta = [fllMagentaField floatValue] / 100;
    else if(field == fllYellowField)
        fillyellow = [fllYellowField floatValue] / 100;
    else if(field == fllBlakField)
        fillblack = [fllBlakField floatValue] / 100;
    else if(field == stkCyanField)
        strokecyan = [stkCyanField floatValue] / 100;
    else if(field == stkMagentaField)
        strokemagenta = [stkMagentaField floatValue] / 100;
    else if(field == stkYellowField)
        strokeyellow = [stkYellowField floatValue] / 100;
    else if(field == stkBlakField)
        strokeblack = [stkBlakField floatValue] / 100;

    [self setNeedsDisplayInRect: strokeColorRect];
    [self setNeedsDisplayInRect: fillColorRect];
    NSLog(@"read line width: %f", linewidth);
}

- (void)setLnCap:(id)sender
{
    linecap = [[sender selectedCell] tag];
}

- (void)setLnJoin:(id)sender
{
    linejoin = [[sender selectedCell] tag];
}

- (void)fllButtPressed:(id)sender
{
    id butt = (NSButton *)sender;
    if([butt state] == NSOnState)
    {
        filled = YES;
        [fllCyanField setStringValue:
            [NSString stringWithFormat:@"%i", (int)fillcyan * 100]];
        [fllCyanField setEditable: YES];
        [fllCyanField setSelectable: YES];
        [fllMagentaField setStringValue:
            [NSString stringWithFormat:@"%i", (int)fillmagenta * 100]];
        [fllMagentaField setEditable: YES];
        [fllMagentaField setSelectable: YES];
        [fllYellowField setStringValue:
            [NSString stringWithFormat:@"%i", (int)fillyellow * 100]];
        [fllYellowField setEditable: YES];
        [fllYellowField setSelectable: YES];
        [fllBlakField setStringValue:
            [NSString stringWithFormat:@"%i", (int)fillblack * 100]];
        [fllBlakField setEditable: YES];
        [fllBlakField setSelectable: YES];
    } else
    {
        filled = NO;
        [fllCyanField setStringValue: @""];
        [fllCyanField setEditable: NO];
        [fllCyanField setSelectable: NO];
        [fllMagentaField setStringValue: @""];
        [fllMagentaField setEditable: NO];
        [fllMagentaField setSelectable: NO];
        [fllYellowField setStringValue: @""];
        [fllYellowField setEditable: NO];
        [fllYellowField setSelectable: NO];
        [fllBlakField setStringValue: @""];
        [fllBlakField setEditable: NO];
        [fllBlakField setSelectable: NO];
    }

    [self setNeedsDisplayInRect: fillColorRect];
}

- (void)stkButtPressed:(id)sender
{
    id butt = (NSButton *)sender;
    if([butt state] == NSOnState) {
        stroked = YES;
        [stkCyanField setStringValue:
            [NSString stringWithFormat:@"%i", (int)strokecyan * 100]];
        [stkCyanField setEditable: YES];
        [stkCyanField setSelectable: YES];
        [stkMagentaField setStringValue:
            [NSString stringWithFormat:@"%i", (int)strokemagenta * 100]];
        [stkMagentaField setEditable: YES];
        [stkMagentaField setSelectable: YES];
        [stkYellowField setStringValue:
            [NSString stringWithFormat:@"%i", (int)strokeyellow * 100]];
        [stkYellowField setEditable: YES];
        [stkYellowField setSelectable: YES];
        [stkBlakField setStringValue:
            [NSString stringWithFormat:@"%i", (int)strokeblack * 100]];
        [stkBlakField setEditable: YES];
        [stkBlakField setSelectable: YES];
    } else {
        stroked = NO;
        [stkCyanField setStringValue: @""];
        [stkCyanField setEditable: NO];
        [stkCyanField setSelectable: NO];
        [stkMagentaField setStringValue: @""];
        [stkMagentaField setEditable: NO];
        [stkMagentaField setSelectable: NO];
        [stkYellowField setStringValue: @""];
        [stkYellowField setEditable: NO];
        [stkYellowField setSelectable: NO];
        [stkBlakField setStringValue: @""];
        [stkBlakField setEditable: NO];
        [stkBlakField setSelectable: NO];
    }

    [self setNeedsDisplayInRect: strokeColorRect];
}

- (void)okCancelPressed:(id)sender;
{
    if(sender == okButt)
        result = NSAlertDefaultReturn;
    else
        result = NSAlertAlternateReturn;
    [[self window] orderOut: self];
    [[NSApplication sharedApplication] stopModal];
}

- (NSDictionary *)properties
{
    NSMutableDictionary *dict;
    NSNumber *num;

    dict = [NSMutableDictionary dictionaryWithCapacity: 1];

    if(ispath) {
        [dict setObject: @"path" forKey: @"type"];
        num = [NSNumber numberWithFloat: flatness];
        [dict setObject: num forKey: @"flatness"];
        num = [NSNumber numberWithInt: linejoin];
        [dict setObject: num forKey: @"linejoin"];
        num = [NSNumber numberWithInt: linecap];
        [dict setObject: num forKey: @"linecap"];
        num = [NSNumber numberWithFloat: miterlimit];
        [dict setObject: num forKey: @"miterlimit"];
        num = [NSNumber numberWithFloat: linewidth];
        [dict setObject: num forKey: @"linewidth"];
    } else {
        [dict setObject: @"text" forKey: @"type"];
    }
    num = [NSNumber numberWithInt: stroked];
    [dict setObject: num forKey: @"stroked"];
    num = [NSNumber numberWithFloat: strokecyan];
    [dict setObject: num forKey: @"strokecyan"];
    num = [NSNumber numberWithFloat: strokemagenta];
    [dict setObject: num forKey: @"strokemagenta"];
    num = [NSNumber numberWithFloat:strokeyellow];
    [dict setObject: num forKey: @"strokeyellow"];
    num = [NSNumber numberWithFloat: strokeblack];
    [dict setObject: num forKey: @"strokeblack"];
    num = [NSNumber numberWithFloat: strokealpha];
    [dict setObject: num forKey: @"strokealpha"];

    num = [NSNumber numberWithInt: filled];
    [dict setObject: num forKey: @"filled"];
    num = [NSNumber numberWithFloat: fillcyan];
    [dict setObject: num forKey: @"fillcyan"];
    num = [NSNumber numberWithFloat: fillmagenta];
    [dict setObject: num forKey: @"fillmagenta"];
    num = [NSNumber numberWithFloat: fillyellow];
    [dict setObject: num forKey: @"fillyellow"];
    num = [NSNumber numberWithFloat: fillblack];
    [dict setObject: num forKey: @"fillblack"];
    num = [NSNumber numberWithFloat: fillalpha];
    [dict setObject: num forKey: @"fillalpha"];

    return dict;
}

- (void)drawRect:(NSRect)rect
{
    NSImage *img;
    NSColor *color;
    NSPoint imgPoint;

    fillColorRect = NSMakeRect(10, 160, 60, 110);
    NSDrawGrayBezel(fillColorRect, fillColorRect);
    if(filled) {
        color = [NSColor colorWithDeviceCyan: fillcyan
                                     magenta: fillmagenta
                                      yellow: fillyellow
                                       black: fillblack
                                       alpha: fillalpha];
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        [color set];
        NSRectFill(NSMakeRect(fillColorRect.origin.x +2,
                              fillColorRect.origin.y +2,
                              fillColorRect.size.width -4,
                              fillColorRect.size.height -4));
    }

    strokeColorRect = NSMakeRect(185, 160, 60, 110);
    NSDrawGrayBezel(strokeColorRect, strokeColorRect);
    if(stroked) {
        color = [NSColor colorWithDeviceCyan: strokecyan
                                     magenta: strokemagenta
                                      yellow: strokeyellow
                                       black: strokeblack
                                       alpha: strokealpha];
        color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
        [color set];
        NSRectFill(NSMakeRect(strokeColorRect.origin.x +2,
                              strokeColorRect.origin.y +2,
                              strokeColorRect.size.width -4,
                              strokeColorRect.size.height -4));
    }

    imgPoint = NSMakePoint(410, 260);
    img = [NSImage imageNamed: @"LineCap1.tiff"];
    [img compositeToPoint: imgPoint operation: NSCompositeSourceOver];
    imgPoint = NSMakePoint(410, 240);
    img = [NSImage imageNamed: @"LineCap2.tiff"];
    [img compositeToPoint: imgPoint operation: NSCompositeSourceOver];
    imgPoint = NSMakePoint(410, 220);
    img = [NSImage imageNamed: @"LineCap3.tiff"];
    [img compositeToPoint: imgPoint operation: NSCompositeSourceOver];
    imgPoint = NSMakePoint(410, 160);
    img = [NSImage imageNamed: @"LineJoin1.tiff"];
    [img compositeToPoint: imgPoint operation: NSCompositeSourceOver];
    imgPoint = NSMakePoint(410, 130);
    img = [NSImage imageNamed: @"LineJoin2.tiff"];
    [img compositeToPoint: imgPoint operation: NSCompositeSourceOver];
    imgPoint = NSMakePoint(410, 100);
    img = [NSImage imageNamed: @"LineJoin3.tiff"];
    [img compositeToPoint: imgPoint operation: NSCompositeSourceOver];
}

@end

