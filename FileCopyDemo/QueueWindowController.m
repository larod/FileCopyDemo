/*
 Copyright 2015 Luis A. Rodríguez-Rivera
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "QueueWindowController.h"
#import "FileCopyOperation.h"
#import "FileCopyManager.h"
#import "FileCopyCell.h"

#define TABLE_BUFFER 2
#define ROW_HEIGHT 60

@interface QueueWindowController ()
@property (weak) IBOutlet NSTableView * tableView;
@property (weak) IBOutlet NSScrollView * scrollView;
@end

@implementation QueueWindowController
int rows;
NSTimer *updateTimer;
NSRect windowFrame;
FileCopyManager * fileCopyManager;

#pragma mark Class Methods
-(void)windowDidLoad {
    [super windowDidLoad];
    _fileCopyOperations = [NSMutableArray new];
    windowFrame = [self.window frame];
    rows = 0;
    
    // ----------------------------------------------------------------------------------------------------
    // Use this line of code if loading an external nib for a row.
    // You'll need to call [tableView makeViewWithIdentifier:@"FileCopyCell" owner:self] in
    // -(NSView *)tableView:(NSTableView *)tableView
    //   viewForTableColumn:(NSTableColumn *)tableColumn
    //                  row:(NSInteger)row
    //[_tableView registerNib:[[NSNib alloc]initWithNibNamed:@"FileCopyCell" bundle:nil] forIdentifier:@"FileCopyCell"];
    // ----------------------------------------------------------------------------------------------------
    
    // ----------------------------------------------------------------------------------------------------
    // This a lazy instantiation of the singleton [FileCopyManager sharedFileCopyManager] the observer
    // keeps track of the number of operations in queue. I use it to size the window as additional
    // operations are added.
    // ----------------------------------------------------------------------------------------------------
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self close];
            [self.window setFrame:windowFrame display:NO animate:NO];
        });
    } else {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
}
-(void)updateProgress:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
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
-(void)cancelAllOperations {
    [fileCopyManager.fileCopyQueue cancelAllOperations];
}
-(void)removeObject:(id)object {
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

// ----------------------------------------------------------------------------------------------------
// These two methods are used to increase or decrase the size of the window depending on how many
// rows are visible in the tableView. They are called from the FileCopyOperationDelegate methods.
// ----------------------------------------------------------------------------------------------------
-(void)addRowSpace:(id)sender {
    NSRect frame = [self.window frame];
    frame.origin.y -= (ROW_HEIGHT - TABLE_BUFFER);
    frame.size.height += (ROW_HEIGHT - TABLE_BUFFER);
    [self.window setFrame:frame display:YES animate:YES];
}
-(void)removeRowSpace:(id)sender {
    NSRect frame = [self.window frame];
    frame.origin.y += (ROW_HEIGHT - TABLE_BUFFER);
    frame.size.height -= (ROW_HEIGHT - TABLE_BUFFER);
    [self.window setFrame:frame display:YES animate:YES];
}
#pragma mark FileCopyOperationDelegate
-(void)fileCopyOperationWillStart:(FileCopyOperation *)fileCopyOperation {
    // ----------------------------------------------------------------------------------------------------
    // This method is called before the [copyfile] actualy starts, the operation is added to the
    // _fileCopyOperations array, [addRowSpace:] sizes the window in proportion to the current operations.
    // For example if two rows are visible and a third operation is added the window will be sized to
    // accommodate three rows.
    // ----------------------------------------------------------------------------------------------------
    [_fileCopyOperations performSelectorOnMainThread:@selector(addObject:) withObject:fileCopyOperation waitUntilDone:YES];
    ++rows;
    if (rows > 1 && rows <= [fileCopyManager maxConcurrentOperations]) {
        [self performSelectorOnMainThread:@selector(addRowSpace:) withObject:nil waitUntilDone:NO];
    }
}
-(void)fileCopyOperationDidFinished:(FileCopyOperation *)fileCopyOperation {
    // ----------------------------------------------------------------------------------------------------
    // This method is called after the [copyfile:] is finished, it allows the queueController to clean
    // things up. First it calls [removeRowSpace:] to size the window depending on how many operations
    // are left in queue and then it calls [removeObject:] to clean the GUI.
    // ----------------------------------------------------------------------------------------------------
    --rows;
    if (rows > 0) {
        [self performSelectorOnMainThread:@selector(removeRowSpace:) withObject:nil waitUntilDone:NO];
    }
    [self performSelectorOnMainThread:@selector(removeObject:) withObject:fileCopyOperation waitUntilDone:YES];
}
#pragma mark NSTableView
// ----------------------------------------------------------------------------------------------------
// These need no explanation, NSTableViewDatasource and NSTableViewDelegate methods.
// ----------------------------------------------------------------------------------------------------
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
