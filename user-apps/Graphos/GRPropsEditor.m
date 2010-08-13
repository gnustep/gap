/*
 Project: Graphos
 GRPropsEditor.m

 Copyright (C) 2000-2010 GNUstep Application Project

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

@implementation GRPropsEditor

- (id)initWithObjectProperties:(NSDictionary *)objprops
{
  NSString *type;

  self = [super init];
  if(self)
    {
      float strokecyan, strokemagenta, strokeyellow, strokeblack, strokealpha;
      float fillcyan, fillmagenta, fillyellow, fillblack, fillalpha;

      [NSBundle loadNibNamed:@"PropertiesEditor" owner:self];
      [[lineCapMatrix cellWithTag: 0] setTitle: @""];
      [[lineCapMatrix cellWithTag: 0] setImage: [NSImage imageNamed: @"LineCap1.tiff"]];
      [[lineCapMatrix cellWithTag: 1] setImage: [NSImage imageNamed: @"LineCap2.tiff"]];

      [[lineJoinMatrix cellWithTag: 0] setTitle: @""];
      [[lineJoinMatrix cellWithTag: 0] setImage: [NSImage imageNamed: @"LineJoin1.tiff"]];

      [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
      
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
            linejoin = linecap = -1;
        }

        filled = (BOOL)[[objprops objectForKey: @"filled"] intValue];
        fillcyan = [[objprops objectForKey: @"fillcyan"] floatValue];
        fillmagenta = [[objprops objectForKey: @"fillmagenta"] floatValue];
        fillyellow = [[objprops objectForKey: @"fillyellow"] floatValue];
        fillblack = [[objprops objectForKey: @"fillblack"] floatValue];
        fillalpha = [[objprops objectForKey: @"fillalpha"] floatValue];
        fillColor = [NSColor colorWithDeviceCyan:fillcyan magenta:fillmagenta yellow:fillyellow black:fillblack alpha:fillalpha];

        stroked = (BOOL)[[objprops objectForKey: @"stroked"] intValue];
        strokecyan = [[objprops objectForKey: @"strokecyan"] floatValue];
        strokemagenta = [[objprops objectForKey: @"strokemagenta"] floatValue];
        strokeyellow = [[objprops objectForKey: @"strokeyellow"] floatValue];
        strokeblack = [[objprops objectForKey: @"strokeblack"] floatValue];
        strokealpha = [[objprops objectForKey: @"strokealpha"] floatValue];
        strokeColor = [NSColor colorWithDeviceCyan:strokecyan magenta:strokemagenta yellow:strokeyellow black:strokeblack alpha:strokealpha];

#if 0
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
        [lineCapMatrix setTarget: self];
        [lineCapMatrix setAction: @selector(setLnCap:)];
        [self addSubview: lineCapMatrix];
        [lineCapMatrix setAllowsEmptySelection:YES];
        [lineCapMatrix deselectAllCells];


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
        [lineJoinMatrix setTarget: self];
        [lineJoinMatrix setAction: @selector(setLnJoin:)];
        [self addSubview: lineJoinMatrix];
        [lineJoinMatrix setAllowsEmptySelection:YES];
        [lineJoinMatrix deselectAllCells];
        

#endif        
        /* disable not used controls */
        if (!ispath)
          {
            [lineCapMatrix setEnabled:NO];
            [lineJoinMatrix setEnabled:NO];
            [flatnessField setEnabled:NO];
            [miterlimitField setEnabled:NO];
            [linewidthField setEnabled:NO];
          }
        
        if(filled)
          [fllButt setState: NSOnState];
        if(stroked)
          [stkButt setState: NSOnState];

        [fillColorWell setColor: fillColor];
        [strokeColorWell setColor: strokeColor];
        
        [flatnessField setStringValue: [NSString stringWithFormat:@"%.2f", flatness]];
        [miterlimitField setStringValue: [NSString stringWithFormat:@"%.2f", miterlimit]];
        [linewidthField setStringValue: [NSString stringWithFormat:@"%.2f", linewidth]];

                
        if(linecap == 0)
          [lineCapMatrix setState: NSOnState atRow: 0 column: 0];
        else if(linecap == 1)
          [lineCapMatrix setState: NSOnState atRow: 1 column: 0];
        else if(linecap == 2)
          [lineCapMatrix setState: NSOnState atRow: 2 column: 0];
        
        if(linejoin == 0)
          [lineJoinMatrix setState: NSOnState atRow: 0 column: 0];
        else if(linejoin == 1)
          [lineJoinMatrix setState: NSOnState atRow: 1 column: 0];
        else if(linejoin == 2)
          [lineJoinMatrix setState: NSOnState atRow: 2 column: 0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidEndEditing:)
                                                     name:@"NSControlTextDidEndEditingNotification" object:nil];

    }
    return self;
}

- (void) dealloc
{
  [super dealloc];
  [strokeColor release];
  [fillColor release];
}

- (int)runModal
{
    NSApplication *app = [NSApplication sharedApplication];
    [app runModalForWindow: propsPanel];
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
}

- (IBAction)setLnCap:(id)sender
{
    linecap = [[sender selectedCell] tag];
}

- (IBAction)setLnJoin:(id)sender
{
    linejoin = [[sender selectedCell] tag];
}

- (IBAction)fllButtPressed:(id)sender
{
    id butt = (NSButton *)sender;
    if([butt state] == NSOnState)
    {
        filled = YES;
        [fillColorWell setEnabled: YES];
      }
    else
      {
        filled = NO;
        [fillColorWell setEnabled: NO];
      }
}

- (IBAction)stkButtPressed:(id)sender
{
    id butt = (NSButton *)sender;
    if([butt state] == NSOnState)
      {
        stroked = YES;
        [strokeColorWell setEnabled: YES];
      }
    else
      {
        stroked = NO;
        [strokeColorWell setEnabled: NO];
      }
}

- (IBAction)okCancelPressed:(id)sender;
{
  fillColor = [[[fillColorWell color] colorUsingColorSpaceName: NSDeviceCMYKColorSpace] retain];
  strokeColor = [[[strokeColorWell color] colorUsingColorSpaceName: NSDeviceCMYKColorSpace] retain];

    if(sender == okButt)
        result = NSAlertDefaultReturn;
    else
        result = NSAlertAlternateReturn;
    [propsPanel orderOut: propsPanel];
    [[NSApplication sharedApplication] stopModal];
}

- (NSDictionary *)properties
{
    NSMutableDictionary *dict;
    NSNumber *num;

    dict = [NSMutableDictionary dictionaryWithCapacity: 1];

    if(ispath)
      {
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
      }
    else
      {
        [dict setObject: @"text" forKey: @"type"];
      }
    num = [NSNumber numberWithInt: stroked];
    [dict setObject: num forKey: @"stroked"];
    num = [NSNumber numberWithFloat: [strokeColor cyanComponent]];
    [dict setObject: num forKey: @"strokecyan"];
    num = [NSNumber numberWithFloat: [strokeColor magentaComponent]];
    [dict setObject: num forKey: @"strokemagenta"];
    num = [NSNumber numberWithFloat: [strokeColor yellowComponent]];
    [dict setObject: num forKey: @"strokeyellow"];
    num = [NSNumber numberWithFloat: [strokeColor blackComponent]];
    [dict setObject: num forKey: @"strokeblack"];
    num = [NSNumber numberWithFloat: [strokeColor alphaComponent]];
    [dict setObject: num forKey: @"strokealpha"];

    num = [NSNumber numberWithInt: filled];
    [dict setObject: num forKey: @"filled"];
    num = [NSNumber numberWithFloat: [fillColor cyanComponent]];
    [dict setObject: num forKey: @"fillcyan"];
    num = [NSNumber numberWithFloat: [fillColor magentaComponent]];
    [dict setObject: num forKey: @"fillmagenta"];
    num = [NSNumber numberWithFloat: [fillColor yellowComponent]];
    [dict setObject: num forKey: @"fillyellow"];
    num = [NSNumber numberWithFloat: [fillColor blackComponent]];
    [dict setObject: num forKey: @"fillblack"];
    num = [NSNumber numberWithFloat: [fillColor alphaComponent]];
    [dict setObject: num forKey: @"fillalpha"];

    return dict;
}


@end

