/* 
 Project: StepSync
 AppController.h
 
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



#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface AppController : NSObject
{
  IBOutlet NSTextField *sourcePathField;
  IBOutlet NSTextField *sourceDirNumberField;
  IBOutlet NSTextField *sourceFileNumberField;
  IBOutlet NSTextField *sourceSizeField;

  IBOutlet NSTextField *targetPathField;
  IBOutlet NSTextField *targetDirNumberField;
  IBOutlet NSTextField *targetFileNumberField;
  IBOutlet NSTextField *targetSizeField;

  IBOutlet NSButton *analyzeButton;
  IBOutlet NSButton *syncButton;
  IBOutlet NSProgressIndicator *progressBar;
  IBOutlet NSTextView *logView;
  
  BOOL analyzeRunning;
  BOOL syncRunning;
}

- (IBAction)setSourcePath:(id)sender;
- (IBAction)setTargetPath:(id)sender;

- (IBAction)analyzeAction:(id)sender;
- (IBAction)syncAction:(id)sender;

@end
