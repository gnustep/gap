// VCFViewer.h (this is -*- ObjC -*-)
// 
// \author: Björn Giesler <giesler@ira.uka.de>
// 
// VCF Content Viewer for GWorkspace
// 
// $Author: rmottola $
// $Locker:  $
// $Revision: 1.3 $
// $Date: 2009/09/28 21:18:03 $


#import <Foundation/Foundation.h>
#import <Inspector/ContentViewersProtocol.h>
#import <Addresses/Addresses.h>
#import <AddressView/ADPersonView.h>


@interface VCFViewer: NSView <ContentViewersProtocol>
{
  id panel;
  NSArray *people;
  int currentPerson;

  NSScrollView *sv;
  NSClipView *cv;
  ADPersonView *pv;
  NSButton *nb, *pb;
  NSTextField *lbl;
  NSButton *ifb, *dfb;

  NSString *bundlePath;

  int index;
}

- (void) nextPerson: (id) sender;
- (void) previousPerson: (id) sender;

- (void) increaseFontSize: (id) sender;
- (void) decreaseFontSize: (id) sender;
@end

