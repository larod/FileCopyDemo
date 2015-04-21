#import "FileCopyManager.h"
#import "FileCopyOperation.h"
#import <Cocoa/Cocoa.h>
#define MAX_CONCURRENT_OPERATIONS 4

@implementation FileCopyManager
@synthesize fileCopyQueue;

+(instancetype)sharedFileCopyManager {
    static FileCopyManager *sharedFileCopyManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedFileCopyManager = [[[self class]alloc]init];
    });
    return sharedFileCopyManager;
}
-(instancetype)init {
    self = [super init];
    if (self) {
        fileCopyQueue = [NSOperationQueue new];
        [fileCopyQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_OPERATIONS];
    }
    return self;
}
-(void)addOPeration:(FileCopyOperation*)opr {
    [fileCopyQueue addOperation:opr];
}
-(int)maxConcurrentOperations {
    return MAX_CONCURRENT_OPERATIONS;
}
@end
