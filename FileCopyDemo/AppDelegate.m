#import "AppDelegate.h"
#import "QueueWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // ----------------------------------------------------------------------------------------------------
    // Setting a default value for destination.
    // ----------------------------------------------------------------------------------------------------
    [_destinationLabel setStringValue:[NSString stringWithFormat:@"~/Desktop"].stringByExpandingTildeInPath];
}
-(IBAction)addOperation:(id)sender {
    // ----------------------------------------------------------------------------------------------------
    // This is some lazy instantiation for the _queueWindorController
    // ----------------------------------------------------------------------------------------------------
    if (!_queueWindowController) {
        _queueWindowController = [[QueueWindowController alloc]initWithWindowNibName:@"Queue"];
    }
    [_queueWindowController showWindow:self];
    
    // ----------------------------------------------------------------------------------------------------
    // Do your checks here, check if the file already exists and handle if the file should be
    // overwritten, or renamed.
    // Beyond this point [addFileCopyOperationWithSource:andDestination:] will only check if the urls are
    // reachable, if the file urls can be reached the operation will be queued.
    // ----------------------------------------------------------------------------------------------------
    [_queueWindowController addFileCopyOperationWithSource:[NSURL fileURLWithPath:_sourceLabel.stringValue] andDestination:[NSURL fileURLWithPath:_destinationLabel.stringValue]];
}
-(IBAction)showQueue:(id)sender {
    // ----------------------------------------------------------------------------------------------------
    // This is some lazy instantiation for the _queueWindorController. If it is intantiated it will toggle
    // open/close the Queue window.
    // ----------------------------------------------------------------------------------------------------
    if (!_queueWindowController) {
        _queueWindowController = [[QueueWindowController alloc]initWithWindowNibName:@"Queue"];
        [_queueWindowController showWindow:self];
    } else {
        [_queueWindowController.window isVisible] ? [_queueWindowController close] : [_queueWindowController showWindow:self];
    }
}
-(IBAction)CancelAll:(id)sender {
    // ----------------------------------------------------------------------------------------------------
    // This method eventually calls [fileQueue cancelAllOperations]
    // ----------------------------------------------------------------------------------------------------
    [_queueWindowController cancelAllOperations];
}
-(QueueWindowController *)getQueueController {
    return _queueWindowController;
}

@end
