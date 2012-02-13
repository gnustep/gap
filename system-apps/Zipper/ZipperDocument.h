#import <Renaissance/GSMarkupDocument.h>

@class Archive, TableViewDataSource;

@interface ZipperDocument : GSMarkupDocument
{
  @private
  	IBOutlet NSTableView *_tableView;
  	
	Archive *_archive;
	TableViewDataSource *_tableViewDataSource;
}

@end
