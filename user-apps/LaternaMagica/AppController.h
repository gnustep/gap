//
//  AppController.h
//  LaternaMagica
//
//  Created by Riccardo Mottola on Mon Jan 16 2006.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <FileTable.h>


@interface AppController : NSObject {
    IBOutlet FileTable    *fileListData;
    IBOutlet NSTableView  *fileListView;
    IBOutlet NSWindow     *controlWin;
    IBOutlet NSWindow     *smallWindow;
    IBOutlet NSImageView  *view;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSButton     *fitButton;
    IBOutlet NSMenuItem   *fullScreenMenuItem;
    IBOutlet NSButton     *fullScreenButton;
    BOOL                  scaleToFit;
    NSWindow              *window;
    NSWindow              *fullWindow;
}

- (IBAction)addFiles:(id)sender;
- (IBAction)setScaleToFit:(id)sender;
- (IBAction)setFullScreen :(id)sender;
- (IBAction)prevImage:(id)sender;
- (IBAction)nextImage:(id)sender;

@end
