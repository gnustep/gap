/*
 Project: Graphos
 GRPropsEditor.m

 Copyright (C) 2000-2011 GNUstep Application Project

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

- (id)init
{
  self = [super init];
  if(self)
    {
      [NSBundle loadNibNamed:@"PropertiesEditor" owner:self];
	
      [self setControlsEnabled: NO];
    }
  return self;
}


- (void)setControlsEnabled:(BOOL)state
{
  [fllButt setEnabled: state];
  [stkButt setEnabled: state];

  [fillColorWell setEnabled: state];
  [strokeColorWell setEnabled: state];
        
  [flatnessField setEnabled: state];
  [miterlimitField setEnabled: state];
  [linewidthField setEnabled: state];

  [lineCapMatrix setEnabled: state];
  [lineJoinMatrix setEnabled: state];

  [flatnessField setEnabled: state];
  [miterlimitField setEnabled: state];
  [linewidthField setEnabled: state];
}

- (void)setProperties:(NSDictionary *)props
{
  NSString *type;
  id obj;

  [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
      
  ispath = NO;
  type = [props objectForKey: @"type"];
  if([type isEqualToString: @"path"])
    ispath = YES;

  if(ispath)
    { 
      linejoin = [[props objectForKey: @"linejoin"] intValue];
      
      miterlimit = [[props objectForKey: @"miterlimit"] floatValue];
      
    }
  else
    {
      miterlimit = 0.0;
      linejoin = -1;
    }

  filled = (BOOL)[[props objectForKey: @"filled"] intValue];
  fillColor = (NSColor *)[props objectForKey: @"fillcolor"];
  [fillColor retain];

  stroked = (BOOL)[[props objectForKey: @"stroked"] intValue];
  strokeColor = (NSColor *)[props objectForKey: @"strokecolor"];
  [strokeColor retain];

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

  [fillColorWell setEnabled: YES];
  [fillColorWell setColor: fillColor];
  [strokeColorWell setEnabled: YES];
  [strokeColorWell setColor: strokeColor];
  
  obj = [props objectForKey: @"flatness"];
  if (obj != nil)
    {
      flatness = [obj floatValue];
      [flatnessField setEnabled: YES];
    }
  else
    flatness = 0;
  [flatnessField setStringValue: [NSString stringWithFormat:@"%.2f", flatness]];

  [miterlimitField setEnabled: YES];
  [miterlimitField setStringValue: [NSString stringWithFormat:@"%.2f", miterlimit]];

  obj = [props objectForKey: @"linewidth"];
  if (obj != nil)
    {
      linewidth = [obj floatValue];
      [linewidthField setEnabled: YES];
    }
  else
    linewidth = 0.0;
  [linewidthField setStringValue: [NSString stringWithFormat:@"%.2f", linewidth]];

  obj = [props objectForKey:@"linecap"];
  if (obj != nil)
    {
      linecap = [[props objectForKey: @"linecap"] intValue];
      [lineCapMatrix setEnabled: YES];
    }
  else
    linecap = -1;
                
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
}

- (void) dealloc
{
  [super dealloc];
  [strokeColor release];
  [fillColor release];
}

- (void)makeKeyAndOrderFront:(id)sender
{
  [propsPanel makeKeyAndOrderFront:sender];
}

- (int)runModal
{
    NSApplication *app = [NSApplication sharedApplication];
    [app runModalForWindow: propsPanel];
    return result;
}

/* as delegate */
- (void)controlTextDidEndEditing:(NSNotification *)aNotification
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
  [fillColor release];
  [strokeColor release];
  fillColor = [[fillColorWell color] retain];
  strokeColor = [[strokeColorWell color] retain];

  if(sender == okButt)
    result = NSAlertDefaultReturn;
  else
    result = NSAlertAlternateReturn;

  [propsPanel orderOut: propsPanel];
  [[NSApplication sharedApplication] stopModal];
}

/* panel delegate */
- (BOOL)windowShouldClose:(id)sender
{
  [self okCancelPressed:sender];
  return YES;
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

