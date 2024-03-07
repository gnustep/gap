/* 
   Project: LaternaMagica
   AppController.h

   Copyright (C) 2006-2015 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2006-01-16

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


#import <AppKit/AppKit.h>

#import <FileTable.h>
#import <LMFlipView.h>
#import "LMWindow.h"

@interface AppController : NSObject
{
    IBOutlet FileTable    *fileListData;
    IBOutlet NSTableView  *fileListView;
    IBOutlet NSWindow     *controlWin;
    IBOutlet NSWindow     *smallWindow;
    IBOutlet LMFlipView   *smallView;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSButton     *fitButton;
    IBOutlet NSTextField  *fieldImageCount;
    IBOutlet NSMenuItem   *fullScreenMenuItem;
    IBOutlet NSButton     *fullScreenButton;
    IBOutlet NSMenuItem   *saveAsMenuItem;
    
    /* save As options */
    IBOutlet NSView        *saveOptionsView;
    IBOutlet NSPopUpButton *fileTypePopUp;
    IBOutlet NSTextField   *jpegCompressionField;
    IBOutlet NSSlider      *jpegCompressionSlider;
    
    BOOL                  scaleToFit;
    NSWindow              *window;
    LMWindow              *fullWindow;
    LMFlipView            *view;
    LMFlipView            *fullView;
    NSSavePanel           *savePanel;
    
    /* preferences */
    IBOutlet NSPanel *prefPanel;
    IBOutlet NSButton *destroyOrRecycleButton;
    IBOutlet NSButton *askBeforeDeletingButton;
    
    /* exporter */
    IBOutlet NSPanel             *exporterPanel;
    IBOutlet NSTextField         *fieldOutputPath;
    IBOutlet NSTextField         *fieldWidth;
    IBOutlet NSTextField         *fieldHeight;
    IBOutlet NSProgressIndicator *exportProgress;
    IBOutlet NSPopUpButton       *popupConstraints;
    IBOutlet NSPopUpButton       *popupFileType;
    IBOutlet NSPopUpButton       *popupFileQuality;
}

- (IBAction)addFiles:(id)sender;
- (IBAction)setScaleToFit:(id)sender;
- (IBAction)setFullScreen:(id)sender;
- (IBAction)prevImage:(id)sender;
- (IBAction)nextImage:(id)sender;
- (IBAction)removeAllImages:(id)sender;
- (IBAction)scrambleList:(id)sender;
- (IBAction)removeImage:(id)sender;
- (IBAction)eraseImage:(id)sender;
- (IBAction)rotateImage90:(id)sender;
- (IBAction)rotateImage180:(id)sender;
- (IBAction)rotateImage270:(id)sender;
- (IBAction)doubleClicked:(id)sender;

- (void)updateImageCount;

- (NSImage *)rotate: (NSImage *)image byAngle:(unsigned)angle;

- (IBAction)saveImageAs:(id)sender;
- (IBAction)setCompressionType:(id)sender;
- (IBAction)setCompressionLevel:(id)sender;

/* exporter */
- (IBAction)exportImages:(id)sender;
- (IBAction)setExportPath:(id)sender;
- (IBAction)execExportImages:(id)sender;

/* preferences */
- (IBAction)showPreferences:(id)sender;
- (IBAction)savePreferences:(id)sender;
- (IBAction)cancelPreferences:(id)sender;

- (void)print:(id)sender;

@end
