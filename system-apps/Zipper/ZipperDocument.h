#import <AppKit/NSDocument.h>

@class Archive, TableViewDataSource;

@interface ZipperDocument : NSDocument
{
  IBOutlet NSTableView *_tableView;
  	
  Archive *_archive;
  IBOutlet TableViewDataSource *_tableViewDataSource;
}

- (TableViewDataSource *)tableViewDataSource;

@end
