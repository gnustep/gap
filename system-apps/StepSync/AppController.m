/* 
 Project: StepSync
 AppController.m
 
 Copyright (C) 2017 Riccardo Mottola
 
 Author: Riccardo Mottola
 
 Created: 2017-02-02
 
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

#import "AppController.h"
#import "FileMap.h"

@implementation AppController

- (IBAction)setSourcePath:(id)sender
{
  NSOpenPanel *openPanel;
  
  openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  if ([openPanel runModal] == NSOKButton)
    {
      NSString *fileName;
    
      fileName = [openPanel filename];
      [sourcePathField setStringValue:fileName];
    }
}

- (IBAction)setTargetPath:(id)sender
{
  NSOpenPanel *openPanel;
  
  openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  if ([openPanel runModal] == NSOKButton)
    {
      NSString *fileName;
    
      fileName = [openPanel filename];
      [targetPathField setStringValue:fileName];
    }  
}

- (IBAction)analyzeAction:(id)sender
{
  NSString *sourceRoot;
  NSString *targetRoot;
  
  sourceRoot = [sourcePathField stringValue];
  targetRoot = [targetPathField stringValue];
  
  [sourceMap release];
  sourceMap = [[FileMap alloc] init];
  [sourceMap setRootPath:sourceRoot];
  [sourceMap analyze];
  [sourceDirNumberField setStringValue:[[NSNumber numberWithUnsignedInt:[[sourceMap directories] count]] description]];
  [sourceFileNumberField setStringValue:[[NSNumber numberWithUnsignedInt:[[sourceMap files] count]] description]];
  
  [targetMap release];
  targetMap = [[FileMap alloc] init];
  [targetMap setRootPath:targetRoot];
  [targetMap analyze];
  [targetDirNumberField setStringValue:[[NSNumber numberWithUnsignedInt:[[targetMap directories] count]] description]];
  [targetFileNumberField setStringValue:[[NSNumber numberWithUnsignedInt:[[targetMap files] count]] description]];

}

- (IBAction)syncAction:(id)sender
{
}


@end
