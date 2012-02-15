#import <Renaissance/GSMarkupDocument.h>

@class Archive, TableViewDataSource;

@interface ZipperDocument : GSMarkupDocument
{
  IBOutlet NSTableView *_tableView;
  	
  Archive *_archive;
  IBOutlet TableViewDataSource *_tableViewDataSource;
}

@end
