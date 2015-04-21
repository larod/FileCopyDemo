#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "FileCopyOperation.h"

@interface FileCopyManager : NSObject

@property (nonatomic, strong, readonly) NSOperationQueue * fileCopyQueue;

+(instancetype)sharedFileCopyManager;
-(void)addOPeration:(FileCopyOperation*)opr;
-(int)maxConcurrentOperations;

@end
