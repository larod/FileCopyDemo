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

#import "SourceViewController.h"
#import "AppDelegate.h"

@implementation SourceViewController

-(void)awakeFromNib {
    //NSLog(@"%s",__func__);
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
    self.wantsLayer = YES;
    self.layer.contents = [[NSImage alloc]initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dropzone" ofType:@"png"]];
}
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *pboardClasses = @[[NSURL class]];
    NSDictionary *pboardDictionary = @{NSPasteboardURLReadingFileURLsOnlyKey: @YES};
    NSArray *pboardObjects = [pboard readObjectsForClasses:pboardClasses options:pboardDictionary];
    
    if (pboardObjects.count == 1) {
        NSURL *url = [pboardObjects firstObject];
        if (![self isDirectory:url]) {
            return NSDragOperationCopy;
        } else {
            return NSDragOperationNone;
        }
    }
    return NSDragOperationNone;
}
-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSURL *fileURL = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
    AppDelegate *appDelegate = (AppDelegate*)[[NSApplication sharedApplication]delegate];
    [appDelegate.sourceLabel setStringValue:fileURL.path];
    return YES;
}
-(BOOL)isDirectory:(NSURL*)url {
    NSNumber *isDir;
    [url getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
    if (isDir.boolValue) {
        return YES;
    } else {
        return NO;
    }
}
@end
