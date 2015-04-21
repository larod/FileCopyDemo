#import <Cocoa/Cocoa.h>
#import "QueueWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSTextField * sourceLabel;
@property (weak) IBOutlet NSTextField * destinationLabel;
@property (strong) QueueWindowController * queueWindowController;

-(IBAction)showQueue:(id)sender;
-(QueueWindowController*)getQueueController;

@end

