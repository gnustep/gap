//
//  AppController.h
//  LaternaMagica
//
//  Created by Riccardo Mottola on Mon Jan 16 2006.
//  Copyright (c) 2006-2007 Carduus. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <FileTable.h>
#import <LMFlipView.h>

@interface AppController : NSObject {
    IBOutlet FileTable    *fileListData;
    IBOutlet NSTableView  *fileListView;
    IBOutlet NSWindow     *controlWin;
    IBOutlet NSWindow     *smallWindow;
    IBOutlet LMFlipView   *smallView;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSButton     *fitButton;
    IBOutlet NSMenuItem   *fullScreenMenuItem;
    IBOutlet NSButton     *fullScreenButton;
    BOOL                  scaleToFit;
    NSWindow              *window;
    NSWindow              *fullWindow;
    NSImageView           *view;
    LMFlipView            *fullView;
}

- (IBAction)addFiles:(id)sender;
- (IBAction)setScaleToFit:(id)sender;
- (IBAction)setFullScreen :(id)sender;
- (IBAction)prevImage:(id)sender;
- (IBAction)nextImage:(id)sender;
- (IBAction)removeImage:(id)sender;
- (IBAction)eraseImage:(id)sender;
- (IBAction)rotateImage90:(id)sender;
- (IBAction)rotateImage180:(id)sender;
- (IBAction)rotateImage270:(id)sender;

@end
