#import <Cocoa/Cocoa.h>
#import "FileCopyOperation.h"

@interface FileCopyViewController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, FileCopyOperationDelegate>

- (void)addFileCopyOperationWithSource:(NSURL*)source andDestination:(NSURL*)destination;
- (void)removeObject:(id)object;

@end
