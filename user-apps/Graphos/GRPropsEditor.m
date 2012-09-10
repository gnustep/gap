/*
 Project: Graphos
 GRPropsEditor.m

 Copyright (C) 2000-2012 GNUstep Application Project

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

- (id)init
{
  self = [super init];
  if(self)
    {
      [NSBundle loadNibNamed:@"PropertiesEditor" owner:self];
      docView = nil;
      [self setControlsEnabled: NO];

      [[NSNotificationCenter defaultCenter] addObserver:self
					    selector:@selector(selectionChanged:)
					    name:@"ObjectSelectionChanged" object:nil];

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

- (void)readProperties
{
  id obj;
  NSDictionary *props;

  [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
      
  [self setControlsEnabled: NO];
  
  props = [docView selectionProperties];
  if (props == nil)
    return;

  filled = [[props objectForKey: @"filled"] boolValue];
  obj = [props objectForKey: @"fillcolor"];
  if (obj != nil)
    {
      fillColor = (NSColor *)obj;
      [fillColor retain];
      [fllButt setEnabled: YES];
      if (filled)
	[fllButt setState: NSOnState];
      else
        [fllButt setState: NSOffState];
      [fillColorWell setEnabled: YES];
    }
  else
    fillColor = nil;
  [fillColorWell setColor: fillColor];

  stroked = [[props objectForKey:@"stroked"] boolValue];
  obj = [props objectForKey: @"strokecolor"];
  if (obj != nil)
    {
      strokeColor = (NSColor *)obj;
      [strokeColor retain];
      [stkButt setEnabled: YES];
      if (stroked)
	[stkButt setState: NSOnState];
      else
        [stkButt setState: NSOffState];
      [strokeColorWell setEnabled: YES];
    }
  else
    strokeColor = nil;
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

  obj = [props objectForKey: @"miterlimit"];
  if (obj != nil)
    {
      miterlimit = [obj floatValue];
      [miterlimitField setEnabled: YES];
    }
  else
    miterlimit = 0;
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
  
  obj = [props objectForKey: @"linejoin"];
  if (obj != nil)
    {
      linejoin = [obj intValue];
      [lineJoinMatrix setEnabled: YES];
    }
  else
    linejoin = -1;

  if(linejoin == 0)
    [lineJoinMatrix setState: NSOnState atRow: 0 column: 0];
  else if(linejoin == 1)
    [lineJoinMatrix setState: NSOnState atRow: 1 column: 0];
  else if(linejoin == 2)
    [lineJoinMatrix setState: NSOnState atRow: 2 column: 0];
}

- (void)setDocView: (GRDocView *)view
{
  docView = view;
}

- (void) dealloc
{
  [super dealloc];
  [strokeColor release];
  [fillColor release];
}

- (void)selectionChanged: (NSNotification *)notif
{
  [self readProperties];
}

- (void)makeKeyAndOrderFront:(id)sender
{
  [propsPanel makeKeyAndOrderFront:sender];
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

  [self valuesChanged: field];
}

- (IBAction)setLnCap:(id)sender
{
  linecap = [[sender selectedCell] tag];
  [self valuesChanged: sender];
}

- (IBAction)setLnJoin:(id)sender
{
  linejoin = [[sender selectedCell] tag];
  [self valuesChanged: sender];
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
  [self valuesChanged: sender];
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
  [self valuesChanged: sender];
}

- (IBAction)valuesChanged:(id)sender
{
  [fillColor release];
  [strokeColor release];
  fillColor = [[fillColorWell color] retain];
  strokeColor = [[strokeColorWell color] retain];
  
  [docView setSelectionProperties: [self properties]];  
}


/* panel delegate */
- (BOOL)windowShouldClose:(id)sender
{
  return YES;
}

- (NSDictionary *)properties
{
  NSMutableDictionary *dict;
  NSNumber *num;

  dict = [NSMutableDictionary dictionaryWithCapacity: 1];

  if ([flatnessField isEnabled])
    {
      num = [NSNumber numberWithFloat: flatness];
      [dict setObject: num forKey: @"flatness"];
    }

  if ([lineJoinMatrix isEnabled])
    {
      num = [NSNumber numberWithInt: linejoin];
      [dict setObject: num forKey: @"linejoin"];
    }

  if ([lineCapMatrix isEnabled])
    {
      num = [NSNumber numberWithInt: linecap];
      [dict setObject: num forKey: @"linecap"];
    }

  if ([miterlimitField isEnabled])
    {
      num = [NSNumber numberWithFloat: miterlimit];
      [dict setObject: num forKey: @"miterlimit"];
    }

  if ([linewidthField isEnabled])
    {
      num = [NSNumber numberWithFloat: linewidth];
      [dict setObject: num forKey: @"linewidth"];
    }

  if (strokeColor != nil)
    {
      [dict setObject: [NSNumber numberWithBool:stroked] forKey: @"stroked"];
      [dict setObject: strokeColor forKey: @"strokecolor"];
    }

  if (fillColor != nil)
    {
      [dict setObject: [NSNumber numberWithBool:filled] forKey: @"filled"];
      [dict setObject: fillColor forKey: @"fillcolor"];
    }

  return dict;
}


@end

