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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "FileCopyOperation.h"

@interface FileCopyManager : NSObject

@property (nonatomic, strong, readonly) NSOperationQueue * fileCopyQueue; ///< Holds all FileCopyOperation objects.

/**
 * Returns the shared file copy manager object for the process.
 * This method always returns the same file copy manager object.
 * @return The default FileCopyManager object.
 */
+(instancetype)sharedFileCopyManager;

/**
 * Adds a FileCopyOperation object to the fileCopyQueue.
 * @param opr The FileCopyOperation to add to the fileCopyQueue.
 */
-(void)addOPeration:(FileCopyOperation*)opr;

/**
 * Returns the maximum concurrent FileCopyOperation objects.
 * @return The maximum count of FileCopyOperation objects that can run concurrently.
 */
-(int)maxConcurrentOperations;

@end
