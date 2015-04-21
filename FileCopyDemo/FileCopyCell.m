#import "FileCopyCell.h"
#import "FileCopyOperation.h"
#import "AppDelegate.h"

@implementation FileCopyCell
@synthesize fileName;
@synthesize status;
@synthesize totalBytes;
@synthesize icon;
@synthesize progressBar;
@synthesize cancelButton;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
-(IBAction)cancelOpr:(id)sender {
    // ----------------------------------------------------------------------------------------------------
    //
    // ----------------------------------------------------------------------------------------------------
    NSButton *button = (NSButton*)sender;
    FileCopyOperation *opr = [(NSTableCellView*)[button superview]objectValue];
    [opr cancel];
    AppDelegate *appDelegate = (AppDelegate*)[[NSApplication sharedApplication]delegate];
    [appDelegate.queueWindowController.fileCopyOperations performSelectorOnMainThread:@selector(removeObject:) withObject:opr waitUntilDone:YES];
}

@end
