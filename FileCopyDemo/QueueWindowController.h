#import <Cocoa/Cocoa.h>
#import "FileCopyOperation.h"

@class FileCopyManager;

@interface QueueWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, FileCopyOperationDelegate> {
    FileCopyManager * fileCopyManager;
}
@property IBOutlet NSTableView * tableView;
@property (nonatomic, strong) NSMutableArray * fileCopyOperations;

- (void)addFileCopyOperationWithSource:(NSURL*)source andDestination:(NSURL*)destination;
- (void)cancelAllOperations;
- (void)removeObject:(id)object;
@end
