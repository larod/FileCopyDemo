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
