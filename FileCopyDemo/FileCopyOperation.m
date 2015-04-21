#import <Cocoa/Cocoa.h>
#import "FileCopyOperation.h"
#import "FileCopyManager.h"
#import "AppDelegate.h"
#include "copyfile.h"

@interface FileCopyOperation()
@property FILE_COPY_STATE fCopyState;
@property int fCopyExitCode;
@end

@implementation FileCopyOperation

- (instancetype)initWithSource:(NSURL *)src andDestination:(NSURL *)dst {
    // ----------------------------------------------------------------------------------------------------
    //
    // ----------------------------------------------------------------------------------------------------
    self = [super init];
    if (self) {
        _srcURL = src;
        _dstURL = dst;
        _fName = src.lastPathComponent;
        
        NSDictionary *fileInfo = [[NSFileManager defaultManager]attributesOfItemAtPath:src.path error:nil];
        _fSize = [fileInfo valueForKey:NSFileSize];
        _bWritten = [NSNumber numberWithLongLong:0];
        
        self.qualityOfService = NSQualityOfServiceUtility;
        self.queuePriority = NSOperationQueuePriorityNormal;
        
        AppDelegate *appDelagate = [[NSApplication sharedApplication]delegate];
        self.delegate = appDelagate.queueWindowController;
    }
    return self;
}
- (int)flags {
    // ----------------------------------------------------------------------------------------------------
    // Need to update flags if accepting directories.
    // ----------------------------------------------------------------------------------------------------
    int flags = COPYFILE_ALL | COPYFILE_NOFOLLOW;
    return flags;
}
static int copyFileCallback(int what, int stage, copyfile_state_t state, const char *sourcePath, const char *destPath, void *context) {
    // ----------------------------------------------------------------------------------------------------
    //
    // ----------------------------------------------------------------------------------------------------
    FileCopyOperation *self = (__bridge FileCopyOperation*)context;
    if ([self isCancelled]) {
        return COPYFILE_QUIT;
    }
    
    switch (what) {
        case COPYFILE_COPY_DATA:
            switch (stage) {
                case COPYFILE_PROGRESS: {
                    off_t copiedBytes;
                    const int returnCode = copyfile_state_get(state, COPYFILE_STATE_COPIED, &copiedBytes);
                    if (returnCode == 0) {
                        self.bWritten = [NSNumber numberWithLongLong:copiedBytes];
                    } else {
                        NSLog(@"Copyfile state error...");
                    }
                }
                    break;
                
                case COPYFILE_ERR: {
                    NSLog(@"Copyfile data error...");
                }
                    break;
            }
            break;
    }
    return COPYFILE_CONTINUE;
}
-(void)main {
    // ----------------------------------------------------------------------------------------------------
    //
    // ----------------------------------------------------------------------------------------------------
    [self.delegate respondsToSelector:@selector(fileCopyOperationWillStart:)] ? [self.delegate fileCopyOperationWillStart:self] : nil;
    
    self.fCopyState = COPY_IN_PROGRESS;
    
    copyfile_state_t copyFileState = copyfile_state_alloc();
    copyfile_state_set(copyFileState, COPYFILE_STATE_STATUS_CB, &copyFileCallback);
    copyfile_state_set(copyFileState, COPYFILE_STATE_STATUS_CTX, (__bridge void*)self);
    
    const char *srcPath = [_srcURL.path fileSystemRepresentation];
    const char *dstPath = [_dstURL.path fileSystemRepresentation];
    
    self.fCopyExitCode = copyfile(srcPath, dstPath, copyFileState, [self flags]);
    self.fCopyState = (self.fCopyExitCode == 0) ? COPY_FINISHED : COPY_FAILED;
    
    [self.delegate respondsToSelector:@selector(fileCopyOperationDidFinished:)] ? [self.delegate fileCopyOperationDidFinished:self] : nil;
    
    copyfile_state_free(copyFileState);
}

@end
