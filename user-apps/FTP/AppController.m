/* 
   Project: FTP

   Copyright (C) 2005-2012 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2005-03-30
   
   Application Controller

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
#import "fileElement.h"

@implementation fileTransmitParms
@end

@implementation AppController

+ (void)initialize
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
    NSFont *font;
    
    if ((self = [super init]))
    {
        connMode = defaultMode;
        
        threadRunning = NO;
        
        font = [NSFont userFixedPitchFontOfSize: 0];
        textAttributes = [NSMutableDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        [textAttributes retain];        
    }
    return self;
}

- (void)dealloc
{
    [textAttributes release];
    [super dealloc];
}

- (void)awakeFromNib
{
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotif
{
    NSArray        *dirList;
    NSUserDefaults *defaults;
    NSString       *readValue;
    NSPort         *port1;
    NSPort         *port2;
    NSArray        *portArray;
    NSConnection   *kitConnection;
	
    /* read the user preferences */
    defaults = [NSUserDefaults standardUserDefaults];
    readValue = [defaults stringForKey:connectionModeKey];

    /* if no value was set for the key we set port as mode */
    if ([readValue isEqualToString:@"default"])
        connMode = defaultMode;
    else if ([readValue isEqualToString:@"port"]  || readValue == nil)
        connMode = portMode;
    else if ([readValue isEqualToString:@"passive"])
        connMode = passiveMode;
    else
        NSLog(@"Unrecognized value in user preferences for %@: %@", connectionModeKey, readValue);
    
    /* set double actions for tables */
    [localView setTarget:self];
    [localView setDoubleAction:@selector(listDoubleClick:)];
    [remoteView setTarget:self];
    [remoteView setDoubleAction:@selector(listDoubleClick:)];
    
    /* startup code */
    local = [[LocalClient alloc] init];
    [local setWorkingDir:[local homeDir]];
    dirList = [local dirContents];
    [progBar setDoubleValue:0.0];  // reset the progress bar
    
    /* we create a data source and set the tableviews */
    localTableData = [[FileTable alloc] init];
    [localTableData initData:dirList];
    [localView setDataSource:localTableData];
    
    remoteTableData = [[FileTable alloc] init];

    /* we update the path menu */
    [self updatePath :localPath :[local workDirSplit]];
    // #### and a release of this array ?!?
	
	// we set up distributed objects
    port1 = [NSPort port];
    port2 = [NSPort port];
    kitConnection = [[NSConnection alloc] initWithReceivePort:port1
													 sendPort:port2];
    [kitConnection setRootObject:self];
	
    /* Ports switched here. */
    portArray = [NSArray arrayWithObjects:port2, port1, nil];
    [NSThread detachNewThreadSelector: @selector(connectWithPorts:)
                             toTarget: [FtpClient class] 
                           withObject: portArray];

    return;
}

- (BOOL)applicationShouldTerminate:(id)sender
{
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotif
{
}

- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName
{
    return NO;
}

/* update the pop-up menu with a new path */
- (void)updatePath :(NSPopUpButton *)path :(NSArray *)pathArray
{
    [path removeAllItems];
    [path addItemsWithTitles:pathArray];
}

/* performs the action of the path pull-down menu
   it navigates upwards the tree
   and works for both the local and remote path */
- (IBAction)changePathFromMenu:(id)sender
{
    Client      *theClient;
    NSTableView *theView;
    FileTable   *theTable;
    NSString    *thePath;
    NSArray     *items;
    int         selectedIndex;
    int         i;
    NSArray    *dirList;

    NSLog(@"%@", [sender class]);
    if (sender == localPath)
    {
        theClient = local;
        theView = localView;
        theTable = localTableData;
    } else
    {
        theClient = ftp;
        theView = remoteView;
        theTable = remoteTableData;
    }
    thePath = [NSString string];
    selectedIndex = [sender indexOfItem:[sender selectedItem]];
    items = [sender itemTitles];
    for (i = [items count] - 1; i >= selectedIndex; i--)
        thePath = [thePath stringByAppendingPathComponent: [items objectAtIndex:i]];
    NSLog(@"selected path: %@", thePath);
    [theClient changeWorkingDir:thePath];
    if ((dirList = [theClient dirContents]) == nil)
        return;
    [theTable initData:dirList];
    [theView reloadData];
    
    [self updatePath :sender :[theClient workDirSplit]];
}

/* perform the action of a double click in a table element
   a directory should be opened, a file down or uploaded
   The same method works for local and remote, detecting them */
- (IBAction)listDoubleClick:(id)sender
{
    Client        *theClient;
    NSTableView   *theView;
    FileTable     *theTable;
    int           elementIndex;
    FileElement   *fileEl;
    NSString      *thePath;
    NSArray       *dirList;
    NSPopUpButton *thePathMenu;

    if (threadRunning)
    {
        NSLog(@"thread was still running");
        return;
    }
    
    theView = sender;
    NSLog(@"%@", [theView class]);
    if (theView == localView)
    {
        theClient = local;
        theTable = localTableData;
        thePathMenu = localPath;
    } else
    {
        theClient = ftp;
        theTable = remoteTableData;
        thePathMenu = remotePath;
    }

    elementIndex = [sender selectedRow];
    if (elementIndex < 0)
    {
        NSLog(@"error: double click with nothing selected");
        return;
    }
    fileEl = [theTable elementAtIndex:elementIndex];
    NSLog(@"element: %@ %d", [fileEl filename], [fileEl isDir]);
    thePath = [NSString stringWithString:[theClient workingDir]];
    thePath = [thePath stringByAppendingPathComponent: [fileEl filename]];
    if ([fileEl isDir])
    {
        NSLog(@"should cd to %@", thePath);
        [theClient changeWorkingDir:thePath];
        if ((dirList = [theClient dirContents]) == nil)
            return;
        [theTable initData:dirList];
        [theView reloadData];
        [self updatePath :thePathMenu :[theClient workDirSplit]];
    } else
    {
        if (theView == localView)
        {
            NSLog(@"should upload %@", thePath);
            [self performStoreFile];
        } else
        {
            NSLog(@"should download %@", thePath);
            [self performRetrieveFile];
        }
    }
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
  if (tableView == localView)
    {
      NSLog(@"local");
      [localTableData sortByIdent: [tableColumn identifier]];
      [localView reloadData];
    }
  else
    {
      NSLog(@"remote");
      [remoteTableData sortByIdent: [tableColumn identifier]];
      [remoteView reloadData];
    }
}

- (void)setInterfaceEnabled:(BOOL)flag
{
    [localView setEnabled:flag];
    [remoteView setEnabled:flag];
    [localPath setEnabled:flag];
    [remotePath setEnabled:flag];
    [buttUpload setEnabled:flag];
    [buttDownload setEnabled:flag];
}

- (void)setThreadRunningState:(BOOL)flag
{
    threadRunning = flag;
    [self setInterfaceEnabled:!flag];
}

- (void)performRetrieveFile
{
    NSEnumerator  *elemEnum;
    FileElement   *fileEl;
    id            currEl;

    [self setThreadRunningState:YES];
	
    // We should actually do a copy of the selection
    elemEnum = [remoteView selectedRowEnumerator];

    while ((currEl = [elemEnum nextObject]) != nil)
    {
        fileEl = [remoteTableData elementAtIndex:[currEl intValue]];
        NSLog(@"should download: %@", [fileEl filename]);
        [ftp retrieveFile:fileEl to:local beingAt:0];
    }
}

- (void)performStoreFile
{
    NSEnumerator  *elemEnum;
    FileElement   *fileEl;
    id            currEl;

    [self setThreadRunningState:YES];

    // We should actually do a copy of the selection
    elemEnum = [localView selectedRowEnumerator];

    while ((currEl = [elemEnum nextObject]) != nil)
    {
        fileEl = [localTableData elementAtIndex:[currEl intValue]];
        NSLog(@"should upload: %@", [fileEl filename]);
        [ftp storeFile:fileEl from:local beingAt:0];
    }
}

- (IBAction)downloadButton:(id)sender
{
    if (threadRunning)
    {
        NSLog(@"thread was still running");
        return;
    }

	[self performRetrieveFile];
}

- (IBAction)uploadButton:(id)sender
{
    if (threadRunning)
    {
        NSLog(@"thread was still running");
        return;
    }

	[self performStoreFile];
}

- (IBAction)localDelete:(id)sender
{
    NSEnumerator  *elemEnum;
    FileElement   *fileEl;
    id            currEl;

    elemEnum = [localView selectedRowEnumerator];
    
    while ((currEl = [elemEnum nextObject]) != nil)
    {
        fileEl = [localTableData elementAtIndex:[currEl intValue]];
        [local deleteFile:fileEl beingAt:0];
    }
}

- (IBAction)remoteDelete:(id)sender
{
    NSEnumerator  *elemEnum;
    FileElement   *fileEl;
    id            currEl;    

    elemEnum = [remoteView selectedRowEnumerator];

    while ((currEl = [elemEnum nextObject]) != nil)
    {
        fileEl = [remoteTableData elementAtIndex:[currEl intValue]];
        [ftp deleteFile:fileEl beingAt:0];
    }
}

- (void)setTransferBegin:(NSString *)name :(unsigned long long)size
{
    [infoMessage setStringValue:name];
    [progBar setDoubleValue:0];
#ifdef WIN32
    DWORD msecs = timeGetTime();
    beginTimeVal.tv_sec=msecs/1000;
    beginTimeVal.tv_usec=(msecs - beginTimeVal.tv_sec*1000) * 1000; 
#else
    gettimeofday(&beginTimeVal, NULL);
#endif
    transferSize = size;
    NSLog(@"begin transfer size: %llu", transferSize);
    if (transferSize == 0)
      {
	[progBar setIndeterminate:YES];
	[progBar startAnimation:nil];
      }
    [mainWin displayIfNeeded];
}

- (void)setTransferProgress:(NSNumber *)bytesTransferred
{
  struct timeval currTimeVal;
  float    speed;
  NSString *speedStr;
  NSString *sizeStr;
  double   percent;
  unsigned long long bytes;

  bytes = [bytesTransferred unsignedLongLongValue];
#ifdef WIN32
    DWORD msecs = timeGetTime();
    currTimeVal.tv_sec=msecs/1000;
    currTimeVal.tv_usec=(msecs - currTimeVal.tv_sec*1000) * 1000; 
#else
    gettimeofday(&currTimeVal, NULL);
#endif
    speed = (float)((double)bytes / (double)(currTimeVal.tv_sec - beginTimeVal.tv_sec));

    if (transferSize > 0)
      {
	percent = ((double)bytes / (double)transferSize) * 100;
	[progBar setDoubleValue:percent];
      }

    speedStr = [NSString alloc];
    if (speed < 1024)
        speedStr = [speedStr initWithFormat:@"%3.2fB/s", speed];
    else if (speed < 1024*1024)
        speedStr = [speedStr initWithFormat:@"%3.2fKB/s", speed/1024];
    else
        speedStr = [speedStr initWithFormat:@"%3.2fMB/s", speed/(1024*1024)];
    [infoSpeed setStringValue:speedStr];
    [speedStr release];

    sizeStr = [NSString alloc];

    if (transferSize < 1024 && transferSize != 0) /* except 0, which means unknown */
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f B", (float)bytes, (float)transferSize];
    else if (transferSize < 1024*1024)
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f KB", (double)bytes/1024, (double)transferSize/1024];
    else
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f MB", (double)bytes/(1024*1024), (double)transferSize/(1024*1024)];
    [infoSize setStringValue:sizeStr];
    [sizeStr release];

    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
}

- (void)setTransferEnd:(NSNumber *)bytesTransferred
{
  struct timeval currTimeVal;
  double         deltaT;
  float          speed;
  NSString       *speedStr;
  NSString       *sizeStr;
  double         percent;
  unsigned long long bytes;
	
  bytes = [bytesTransferred unsignedLongLongValue];

#ifdef WIN32
    DWORD msecs = timeGetTime();
    currTimeVal.tv_sec=msecs/1000;
    currTimeVal.tv_usec=(msecs - currTimeVal.tv_sec*1000) * 1000; 
#else
    gettimeofday(&currTimeVal, NULL);
#endif
    deltaT = (currTimeVal.tv_sec - beginTimeVal.tv_sec)+((double)(currTimeVal.tv_usec - beginTimeVal.tv_usec)/1000000);
    speed = (float)((double)bytes / deltaT);
    NSLog(@"Elapsed time: %f", (float)deltaT);
    percent = ((double)bytes / (double)transferSize) * 100;
    speedStr = [NSString alloc];
    if (speed < 1024)
        speedStr = [speedStr initWithFormat:@"%3.2fB/s", speed];
    else if (speed < 1024*1024)
        speedStr = [speedStr initWithFormat:@"%3.2fKB/s", speed/1024];
    else
        speedStr = [speedStr initWithFormat:@"%3.2fMB/s", speed/(1024*1024)];
    [infoSpeed setStringValue:speedStr];
    [speedStr release];

    sizeStr = [NSString alloc];
    if (transferSize < 1024)
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f B", (float)bytes, (float)transferSize];
    else if (transferSize < 1024*1024)
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f KB", (double)bytes/1024, (double)transferSize/1024];
    else
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f MB", (double)bytes/(1024*1024), (double)transferSize/(1024*1024)];
    [infoSize setStringValue:sizeStr];
    [sizeStr release];
    
    if ([progBar isIndeterminate])
      {
	[progBar stopAnimation:nil];
	[progBar setIndeterminate:NO];
      }
    [progBar setDoubleValue:percent];
    [mainWin displayIfNeeded];
}

- (IBAction)disconnect:(id)sender
{
    [ftp disconnect];
    [mainWin setTitle:@"FTP"];

}

- (IBAction)showPrefPanel:(id)sender
{
    [prefPanel makeKeyAndOrderFront:self];
    switch (connMode)
    {
        case defaultMode:
            [portType selectCellWithTag:0];
            break;
        case portMode:
            [portType selectCellWithTag:1];
            break;
        case passiveMode:
            [portType selectCellWithTag:2];
            break;
        default:
            NSLog(@"Unexpected mode on pref pane setup.");
    }
}

- (IBAction)prefSave:(id)sender
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"tag... %d", [[portType selectedCell] tag]);
    switch ([[portType selectedCell] tag])
    {
        case 0:
            //default
            NSLog(@"default");
            connMode = defaultMode;
            [ftp setPortDefault];
            [defaults setObject:@"default" forKey:connectionModeKey];
            break;
        case 1:
            //port
            NSLog(@"port");
            connMode = portMode;
            [ftp setPortPort];
            [defaults setObject:@"port" forKey:connectionModeKey];
            break;
        case 2:
            // passive
            NSLog(@"passive");
            connMode = passiveMode;
            [ftp setPortPassive];
            [defaults setObject:@"passive" forKey:connectionModeKey];
            break;
        default:
            NSLog(@"unexpected selection");
    }
    [prefPanel performClose:nil];
}

- (IBAction)prefCancel:(id)sender
{
    [prefPanel performClose:nil];
}

- (IBAction)showFtpLog:(id)sender
{
    [logWin makeKeyAndOrderFront:self];
}

/**
 Called by the server object to register itself.
 */
- (void)setServer:(id)anObject
{
	ftp = (FtpClient*)[anObject retain];
	
	NSLog(@"FTP server object set");
    return;
}

- (IBAction)appendTextToLog:(NSString *)textChunk
{
  NSAttributedString *attrStr;
    
  attrStr = [[NSAttributedString alloc] initWithString: textChunk
					    attributes: textAttributes];

  /* add the textChunk to the NSTextView's backing store as an attributed string */
  [[logTextField textStorage] appendAttributedString: attrStr];


    
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
  [logTextField scrollRangeToVisible:NSMakeRange([[logTextField string] length], 0)];

  [attrStr autorelease];
}

/* --- connection panel methods --- */
- (IBAction)showConnPanel:(id)sender
{
    [connectPanel makeKeyAndOrderFront:self];
}

- (IBAction)connectConn:(id)sender
{
    NSArray *dirList;
    char    tempStr[1024];
    char    tempStr2[1024];
    
    [connectPanel performClose:nil];
    [mainWin makeKeyAndOrderFront:self];

    ftp = [ftp initWithController:self :connMode];
    [[connAddress stringValue] getCString:tempStr];
    if ([ftp connect:[connPort intValue] :tempStr] < 0)
    {
        NSRunAlertPanel(@"Error", @"Connection failed.\nCheck that you typed the host name correctly.", @"Ok", nil, nil);
        NSLog(@"connection failed in connectConn");
        return;
    }
    if ([connAnon state] == NSOnState)
    {
        strcpy(tempStr, "anonymous");
        strcpy(tempStr2, "user@myhost.com");
    } else
    {
        [[connUser stringValue] getCString:tempStr];
        [[connPass stringValue] getCString:tempStr2];
    }
    if ([ftp authenticate:tempStr :tempStr2] < 0)
    {
        NSRunAlertPanel(@"Error", @"Authentication failed.\nCheck that your username and password are correct.", @"Ok", nil, nil);
        NSLog(@"authentication failed.");
        return;
    } else
    {
        [ftp setWorkingDir:[ftp homeDir]];
        if ((dirList = [ftp dirContents]) == nil)
            return;
        [remoteTableData initData:dirList];
        [remoteView setDataSource:remoteTableData];

        /* update the path menu */
        [self updatePath :remotePath :[ftp workDirSplit]];
        
        /* set the window title */
        [mainWin setTitle:[connAddress stringValue]];
    }
}

- (IBAction)cancelConn:(id)sender
{
    [connectPanel performClose:nil];
}

- (IBAction)anonymousConn:(id)sender
{
    if ([connAnon state] == NSOnState)
    {
        [connUser setEnabled:NO];
        [connPass setEnabled:NO];
    } else
    {
        [connUser setEnabled:YES];
        [connPass setEnabled:YES];
    }
}


- (void)showAlertDialog:(NSString *)message
{
    [message retain];
    NSRunAlertPanel(@"Attention", message, @"Ok", nil, nil);
    [message release];
}

- (connectionModes)connectionMode
{
    return connMode;
}

@end
