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
       [NSBundle loadNibNamed:@"PropertiesEditor" owner:self];
      
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
        fillColor = (NSColor *)[objprops objectForKey: @"fillcolor"];

        stroked = (BOOL)[[objprops objectForKey: @"stroked"] intValue];
        strokeColor = (NSColor *)[objprops objectForKey: @"strokecolor"];

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
  fillColor = [[fillColorWell color] retain];
  strokeColor = [[strokeColorWell color] retain];

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
    [dict setObject: strokeColor forKey: @"strokecolor"];

    num = [NSNumber numberWithInt: filled];
    [dict setObject: num forKey: @"filled"];
    [dict setObject: fillColor forKey: @"fillcolor"];

    return dict;
}


@end

