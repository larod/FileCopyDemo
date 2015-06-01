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

#import "AppDelegate.h"
#import "QueueWindowController.h"
#import "FileCopyViewController.h"

@interface AppDelegate()
@property (weak) IBOutlet NSButton * queueButton;
@property (weak) IBOutlet NSButton * fileCopyButton;
@end

@implementation AppDelegate
FileCopyViewController *_fileCopyViewController;
QueueWindowController * _queueWindowController;

-(IBAction)addQueueOperation:(id)sender {
    // ----------------------------------------------------------------------------------------------------
    // This is some lazy instantiation for the _queueWindorController
    // ----------------------------------------------------------------------------------------------------
    if (!_queueWindowController) {
        _queueWindowController = [[QueueWindowController alloc]initWithWindowNibName:@"Queue"];
        [_fileCopyButton setEnabled:NO];
    }
    [_queueWindowController showWindow:nil];
    
    // ----------------------------------------------------------------------------------------------------
    // Do your checks here, check if the file already exists and handle if the file should be
    // overwritten, or renamed.
    // Beyond this point [addFileCopyOperationWithSource:andDestination:] will only check if the urls are
    // reachable, if the file urls can be reached the operation will be queued.
    // ----------------------------------------------------------------------------------------------------
    
    [_queueWindowController addFileCopyOperationWithSource:[NSURL fileURLWithPath:_sourceLabel.stringValue] andDestination:[NSURL fileURLWithPath:_destinationLabel.stringValue]];
    
}
-(IBAction)addFileCopyWindowOperation:(id)sender {
    if (!_fileCopyViewController) {
        _fileCopyViewController = [[FileCopyViewController alloc]initWithWindowNibName:@"FileCopyWindow"];
        [_queueButton setEnabled:NO];
    }
    [_fileCopyViewController showWindow:nil];
    
    [_fileCopyViewController addFileCopyOperationWithSource:[NSURL fileURLWithPath:_sourceLabel.stringValue]  andDestination:[NSURL fileURLWithPath:_destinationLabel.stringValue]];
}
-(IBAction)showQueue:(id)sender {
    // ----------------------------------------------------------------------------------------------------
    // Comment
    // ----------------------------------------------------------------------------------------------------
    if (!_queueWindowController) {
        _queueWindowController = [[QueueWindowController alloc]initWithWindowNibName:@"Queue"];
        [_queueWindowController showWindow:nil];
    }
    [_queueWindowController showWindow:nil];
    [_queueWindowController.window makeKeyWindow];
}
-(IBAction)showFileCopyWindow:(id)sender {
    // ----------------------------------------------------------------------------------------------------
    // Comment
    // ----------------------------------------------------------------------------------------------------
    if (!_fileCopyViewController) {
        _fileCopyViewController = [[FileCopyViewController alloc]initWithWindowNibName:@"FileCopyWindow"];
    }
    [_fileCopyViewController showWindow:nil];
    [_fileCopyViewController.window makeKeyWindow];
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
