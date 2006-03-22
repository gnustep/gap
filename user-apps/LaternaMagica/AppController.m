//
//  AppController.m
//  LaternaMagica
//
//  Created by Riccardo Mottola on Mon Jan 16 2006.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (id) init
{
    if (self = [super init])
    {
        // add an observer for the file table view
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:fileListView];
        // add an observer for the window resize
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResize:) name:NSWindowDidResizeNotification object:window];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setScaleToFit:self];

    [view setImageAlignment:NSImageAlignTopLeft];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changeImage:(NSString *) file
{
    NSImage *image;

    image = [[NSImage alloc] initByReferencingFile:file];
    [window orderWindow:NSWindowBelow relativeTo:[controlWin windowNumber]];
    [view setImage: image];
    [view setFrameSize:[window frame].size];
}


- (void)addFile:(NSString *)filename
{
    [fileListData addPath:filename];
    [fileListView reloadData];
}

- (void)addFiles:(id)sender
{
    NSOpenPanel   *openPanel;
    NSArray       *files;
    NSEnumerator  *e;
    NSString      *filename;
    NSFileManager *fmgr;
    NSDictionary  *attrs;

    openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:YES];
    if ([openPanel runModalForTypes:NULL] != NSOKButton)
    {
        return;
    }

    files = [openPanel filenames];
    e = [files objectEnumerator];
    fmgr = [NSFileManager defaultManager];
    while (filename = (NSString*)[e nextObject]) {
        attrs = [fmgr fileAttributesAtPath:filename traverseLink:YES];
        if (attrs)
            if ([attrs objectForKey:NSFileType] == NSFileTypeDirectory)
            {
                NSArray      *dirContents;
                NSEnumerator *e2;
                NSString     *filename2;
                NSDictionary  *attrs2;

                dirContents = [fmgr subpathsAtPath:filename];
                e2 = [dirContents objectEnumerator];
                while (filename2 = (NSString*)[e2 nextObject])
                {
                    NSString *tempName;

                    tempName = [filename stringByAppendingPathComponent:filename2];
                    attrs2 = [[NSFileManager defaultManager] fileAttributesAtPath:tempName traverseLink:YES];
                    if (attrs2)
                    {
                        if ([attrs2 objectForKey:NSFileType] != NSFileTypeDirectory)
                        {
                            [self addFile:tempName];
                        }
                    }
                }
            } else {
                [self addFile:filename];
        } else
        {
            NSLog(@"open panel did not return a valid path");
        }
    }
}

- (IBAction)setScaleToFit:(id)sender
{
    if ([fitButton state] == NSOnState)
    {
        scaleToFit = YES;
        [view setImageScaling:NSScaleToFit];
    } else
    {
        scaleToFit = NO;
        [view setImageScaling:NSScaleNone];
    }
    [scrollView setHasVerticalScroller:!scaleToFit];
    [scrollView setHasHorizontalScroller:!scaleToFit];
    [self scaleView];
}

// method called as a notification from the selection change
- (void)_selectionDidChange :(NSNotification *)notif
{
    NSTableView *table;
    
    table = [notif object];
    [self changeImage:[fileListData pathAtIndex:[table selectedRow]]];
    [self scaleView];
}

// method called as a notification from the window resize
// or if scale preferences changed
- (void)_windowDidResize :(NSNotification *)notif
{
    [view setFrameSize:[window frame].size];
    [self scaleView];
}

// scale image according to options
- (void)scaleView
{
    if (scaleToFit) {
        NSSize imageSize;
        NSSize rectSize;
        NSAffineTransform *at;
        float scaleH, scaleW;
        float scale;

        imageSize = [[view image] size];
        rectSize =  [window frame].size;

        scaleW = rectSize.width / imageSize.width;
        scaleH =  rectSize.height / imageSize.height;

        if (scaleW < scaleH)
            scale = scaleW;
        else
            scale = scaleH;
        NSLog(@"sclae: %f", scale);
        at = [NSAffineTransform transform];
        [at scaleBy:scale];
        [view setFrameSize:[at transformSize:imageSize]];
        [view setNeedsDisplay:YES];
    }
}

@end
