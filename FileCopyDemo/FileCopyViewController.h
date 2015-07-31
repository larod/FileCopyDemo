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

#import <Cocoa/Cocoa.h>
#import "FileCopyOperation.h"

@interface FileCopyViewController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, FileCopyOperationDelegate>

/**
 * Creates a FileCopyOperation object with the parameters given and
 * adds the operation to the FileCopyManager fileCopyQueue.
 * @param source The source URL.
 * @param destination The destination URL.
 * @see FileCopyManager
 * @see FileCopyOperation
 * @return void
 */
-(void)addFileCopyOperationWithSource:(NSURL*)source andDestination:(NSURL*)destination;

/**
 * Removes the FileCopyOperation represented object from the table view and the fileCopyOperations array.
 * @param object The object to be removed.
 */
-(void)removeObject:(id)object;
@end
