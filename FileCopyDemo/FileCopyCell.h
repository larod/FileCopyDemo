#import <Cocoa/Cocoa.h>

@class FileCopyOperation;

@interface FileCopyCell : NSTableCellView

@property (nonatomic, weak) IBOutlet NSTextField * fileName;
@property (nonatomic, weak) IBOutlet NSTextField * status;
@property (nonatomic, weak) IBOutlet NSTextField * totalBytes;
@property (nonatomic, weak) IBOutlet NSButton * cancelButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator * progressBar;
@property (nonatomic, weak) IBOutlet NSImageView * icon;

@end
