/*
 This implementation is based on the RSTLCopyOperation implementation
 created by Doug Russell Copyright (c) 2013 Doug Russell. All rights reserved.
 
 I modified that implementation to be more friendly to use with OS X 10.10 operation queues,
 I highly recommend everyone to study his implementation which is more complete and can
 handle folders. I added an additional protocol and more properties to make it easy for devs
 to update guis.
 
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

typedef NS_ENUM(int8_t, FILE_COPY_STATE) {
    COPY_NOT_STARTED,
    COPY_IN_PROGRESS,
    COPY_FINISHED,
    COPY_FAILED,
};

// Delegate declaration
@protocol FileCopyOperationDelegate;

// FileCopyOperation interface
@interface FileCopyOperation : NSOperation

@property (nonatomic, readonly) NSURL * srcURL; ///< Source URL.
@property (nonatomic, readonly) NSURL * dstURL; ///< Destination URL.
@property (nonatomic, readonly) NSString * fName; ///< File name of the media being copied.
@property (nonatomic, readonly) NSNumber * fSize; ///< File size of the file being copied.
@property (nonatomic) NSNumber * bWritten; ///< Bytes written so far.

@property (readonly) FILE_COPY_STATE fCopyState; ///< FileCopyOperation current state.
@property (weak) id<FileCopyOperationDelegate> delegate; ///< FileCopyOperationDelegate.
@property (readonly) int fCopyExitCode; ///< FileCopyOperation exit code.

/**
 * Creates a new FileCopyOperationObject.
 * @param src Source URL.
 * @param dst Destination URL.
 * @param delegata The FileCopyOperationDelegate
 * @return A new FileCopyOperation object initialized with the parameters given.
 */
- (instancetype)initWithSource:(NSURL *)src andDestination:(NSURL *)dst andDelegate:(id <FileCopyOperationDelegate>)delegate;

@end

/** Delegate implementation */
@protocol FileCopyOperationDelegate <NSObject>
@optional
/**
 * This delegate method gets called when the FileCopyOperation is about to start.
 * Any GUI prep code goes here.
 * @param fileCopyOperation The FileCopyOperation object.
 */
- (void)fileCopyOperationWillStart:(FileCopyOperation*)fileCopyOperation;

/**
 * This delegate method gets called when the FileCopyOperation finishes.
 * Any cleanup code goes here.
 * @param fileCopyOperation The FileCopyOperation object.
 */
- (void)fileCopyOperationDidFinished:(FileCopyOperation*)fileCopyOperation;

/**
 * This delegate method gets called when FileCopyOperation writes data.
 * Is used to update file copy progress.
 * @param fileCopyOperation The FileCopyOperation object.
 */
- (void)fileCopyOperationStatusUpdate:(FileCopyOperation*)fileCopyOperation;
@end
