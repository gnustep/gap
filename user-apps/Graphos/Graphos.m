/*
 Project: Graphos
 Graphos.m

 Copyright (C) 2000-2011 GNUstep Application Project

 Author: Enrico Sersale (original implementation)
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

#import "Graphos.h"
#import "GRFunctions.h"
#import "GRDocument.h"

@implementation Graphos

- (id) init
{
  if ((self = [super init]))
    {
      [[NSNotificationCenter defaultCenter] addObserver:self
					    selector:@selector(mainWindowChanged:)
					    name:NSWindowDidBecomeMainNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self
					    selector:@selector(mainWindowResigned:)
					    name:NSWindowDidResignMainNotification object:nil];
      objectInspector = nil;
    }
  return self;
}

- (void)dealloc
{
  [tools release];
  [objectInspector release];
  [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    tools = [[GRToolsWindow alloc] init];
    [tools display];
    [tools orderFront:nil];
}

- (IBAction)showObjectInspector: (id)sender
{
  if (objectInspector == nil)
    objectInspector = [[GRPropsEditor alloc] init];
  [objectInspector setDocView: [[[NSDocumentController sharedDocumentController] currentDocument] docView]];
  [objectInspector readProperties];
  [objectInspector makeKeyAndOrderFront: sender];
}

- (GRPropsEditor *)objectInspector
{
  return objectInspector;
}

- (void)setToolType:(ToolType)type
{
    tooltype = type;
    [tools setButtonsPositions: tooltype];
}

- (ToolType)currentToolType
{
    return tooltype;
}

// FIXME This is pretty ugly. GRText is the only thing that uses
// it. maybe its possible to get rid of it.
- (void)updateCurrentWindow
{
    NSWindow *curWin = [[[[[NSDocumentController sharedDocumentController] currentDocument] windowControllers] objectAtIndex: 0] window];
    [curWin display];
}

/* notification */
- (void)mainWindowChanged :(NSNotification *)notif
{
  [objectInspector setDocView: [[[NSDocumentController sharedDocumentController] currentDocument] docView]];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

/* notification */
- (void)mainWindowResigned :(NSNotification *)notif
{
  [objectInspector setDocView: nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}


@end
