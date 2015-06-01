#import "FileCopyViewController.h"
#import "FileCopyManager.h"
#import "FileCopyCell.h"

@interface FileCopyViewController ()
@property (weak) IBOutlet NSTableView * tableView;
@property (nonatomic) NSMutableArray * fileCopyOperations;
@end

@implementation FileCopyViewController
FileCopyManager * fileCopyManager;
NSTimer *updateTimer;

- (void)windowDidLoad {
    [super windowDidLoad];
    _fileCopyOperations = [NSMutableArray new];
    if (!fileCopyManager) {
        fileCopyManager = [FileCopyManager sharedFileCopyManager];
        [fileCopyManager.fileCopyQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:(void*)fileCopyManager];
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // ----------------------------------------------------------------------------------------------------
    // If I let each operation notify when it has new data, they will slow down the app considerably with
    // many [tableView reloadData] messages. Instead if there are operations in the queue I update the
    // table every 1ms. If there are no more operations in queue the window will close and the timer will
    // get invalidated.
    // ----------------------------------------------------------------------------------------------------
    if (fileCopyManager.fileCopyQueue.operationCount == 0) {
        if (updateTimer) {
            [updateTimer invalidate];
        }
        [self performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:NO];
    } else {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:_tableView selector:@selector(reloadData) userInfo:nil repeats:YES];
    }
}
-(void)addFileCopyOperationWithSource:(NSURL *)source andDestination:(NSURL *)destination {
    NSError *srcError, *dstError;
    // ----------------------------------------------------------------------------------------------------
    // This method checks if the source and destination urls are reachable and creates a FileCopyOperation
    // once the operation is created is added to the queue using [fileCopyManager addOperation:].
    // ----------------------------------------------------------------------------------------------------
    if ([source checkResourceIsReachableAndReturnError:&srcError] && [destination checkResourceIsReachableAndReturnError:&dstError]) {
        FileCopyOperation *opr = [[FileCopyOperation alloc]initWithSource:source andDestination:[NSURL fileURLWithPath:[destination.path stringByAppendingPathComponent:source.lastPathComponent] isDirectory:NO] andDelegate:self];
        [fileCopyManager addOPeration:opr];
    } else {
        srcError ? [NSAlert alertWithError:srcError] : nil;
        dstError ? [NSAlert alertWithError:dstError] : nil;
    }
}
-(IBAction)cancelAllOperations:(id)sender {
    [fileCopyManager.fileCopyQueue cancelAllOperations];
}
- (void)removeObject:(id)object {
    // ----------------------------------------------------------------------------------------------------
    // This method is called from -(void)fileCopyOperationDidFinished:(FileCopyOperation *)fileCopyOperation
    // it finds the index of the object to be removed, if is found it removes the row from the table and
    // the _fileCopyOperations array.
    // ----------------------------------------------------------------------------------------------------
    NSInteger row = [_fileCopyOperations indexOfObject:object];
    if (row != NSNotFound) {
        [_tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectNone];
        [_fileCopyOperations removeObject:object];
    }
}
#pragma mark FileCopyOperationDelegate
-(void)fileCopyOperationWillStart:(FileCopyOperation *)fileCopyOperation {
    [_fileCopyOperations performSelectorOnMainThread:@selector(addObject:) withObject:fileCopyOperation waitUntilDone:YES];
}
-(void)fileCopyOperationDidFinished:(FileCopyOperation *)fileCopyOperation {
    [self performSelectorOnMainThread:@selector(removeObject:) withObject:fileCopyOperation waitUntilDone:YES];
}
#pragma mark NSTableView
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_fileCopyOperations count];
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [_fileCopyOperations objectAtIndex:row];
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    FileCopyCell *cell = [tableView makeViewWithIdentifier:@"FileOperationCell" owner:self];
    FileCopyOperation *opr = [_fileCopyOperations objectAtIndex:row];
    
    [cell.fileName setStringValue:[NSString stringWithFormat:@"Copying \"%@\"",opr.fName]];
    [cell.progressBar setDoubleValue:((opr.bWritten.doubleValue / opr.fSize.doubleValue) * 100)];
    [cell.totalBytes setStringValue:[NSString stringWithFormat:@"of %@",[NSByteCountFormatter stringFromByteCount:opr.fSize.longLongValue countStyle:NSByteCountFormatterCountStyleFile]]];
    // At some point add time left to the status (Time remainig (elapsedTime/data processed) * dataLeft = timeLeft).
    [cell.status setStringValue:[NSString stringWithFormat:@"%@",[NSByteCountFormatter stringFromByteCount:opr.bWritten.longLongValue countStyle:NSByteCountFormatterCountStyleFile]]];
    [cell.icon setImage:[[NSWorkspace sharedWorkspace]iconForFile:opr.srcURL.path]];
    return cell;
}
@end
