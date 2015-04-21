//  RSTLCopyOperation.m
//  This implementation is based on the RSTLCopyOperation implementation
//  created by Doug Russell Copyright (c) 2013 Doug Russell. All rights reserved.
//
// I modified that implementation to be more friendly to use with OS X 10.10 operation queues,
// I highly recommend everyone to study his implementation which is more complete and can
// handle folders. I added an additional protocol and more properties to make it easy for devs
// to update guis.

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

@property (nonatomic, readonly) NSURL * srcURL;
@property (nonatomic, readonly) NSURL * dstURL;
@property (nonatomic, readonly) NSString * fName;
@property (nonatomic, readonly) NSNumber * fSize;
@property (nonatomic) NSNumber * bWritten;

@property (readonly) FILE_COPY_STATE fCopyState;
@property (weak) id<FileCopyOperationDelegate> delegate;
@property (readonly) int fCopyExitCode;

- (instancetype)initWithSource:(NSURL*)src andDestination:(NSURL*)dst;

@end

// Delegate implementation
@protocol FileCopyOperationDelegate <NSObject>
@optional
- (void)fileCopyOperationWillStart:(FileCopyOperation*)fileCopyOperation;
- (void)fileCopyOperationDidFinished:(FileCopyOperation*)fileCopyOperation;
- (void)fileCopyOperationStatusUpdate:(FileCopyOperation*)fileCopyOperation;
@end
