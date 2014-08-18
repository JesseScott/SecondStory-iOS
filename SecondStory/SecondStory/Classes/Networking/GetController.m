

#import "GetController.h"

#import "NetworkManager.h"

#include <CFNetwork/CFNetwork.h>

#pragma mark * GetController

@interface GetController () <UITextFieldDelegate, NSStreamDelegate>

// things for IB

@property (nonatomic, strong, readwrite) IBOutlet UITextField *               urlText;
@property (nonatomic, strong, readwrite) IBOutlet UIImageView *               imageView;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *                   statusLabel;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView *   activityIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIBarButtonItem *           getOrCancelButton;

- (IBAction)getOrCancelAction:(id)sender;

// Properties that don't need to be seen by the outside world.

@property (nonatomic, assign, readonly ) BOOL              isReceiving;
@property (nonatomic, strong, readwrite) NSInputStream *   networkStream;
@property (nonatomic, copy,   readwrite) NSString *        filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *  fileStream;

@end

@implementation GetController

#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)receiveDidStart
{
    // Clear the current image so that we get a nice visual cue if the receive fails.
    self.imageView.image = [UIImage imageNamed:@"NoImage.png"];
    self.statusLabel.text = @"Receiving";
    self.getOrCancelButton.title = @"Cancel";
    [self.activityIndicator startAnimating];
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
    self.statusLabel.text = statusString;
}

- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        assert(self.filePath != nil);
        self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
        statusString = @"GET succeeded";
    }
    self.statusLabel.text = statusString;
    self.getOrCancelButton.title = @"Get";
    [self.activityIndicator stopAnimating];
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

- (BOOL)isReceiving
{
    return (self.networkStream != nil);
}

- (void)startReceive
    // Starts a connection to download the current URL.
{
    BOOL                success;
    NSURL *             url;
    
    assert(self.networkStream == nil);      // don't tap receive twice in a row!
    assert(self.fileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto

    // First get and check the URL.
    
    url = [[NetworkManager sharedInstance] smartURLForString:self.urlText.text];
    success = (url != nil);

    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.statusLabel.text = @"Invalid URL";
    } else {

        // Open a stream for the file we're going to receive into.

        self.filePath = [[NetworkManager sharedInstance] pathForTemporaryFileWithPrefix:@"Get"];
        assert(self.filePath != nil);
        
        self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        assert(self.fileStream != nil);
        
        [self.fileStream open];

        // Open a CFFTPStream for the URL.

        self.networkStream = CFBridgingRelease(
            CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url)
        );
        assert(self.networkStream != nil);
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];
        
        // Tell the UI we're receiving.
        
        [self receiveDidStart];
    }
}

- (void)stopReceiveWithStatus:(NSString *)statusString
    // Shuts down the connection and displays the result (statusString == nil) 
    // or the error status (otherwise).
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
    // An NSStream delegate callback that's called when events happen on our 
    // network stream.
{
    #pragma unused(aStream)
    assert(aStream == self.networkStream);

    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self updateStatus:@"Opened connection"];
        } break;
        case NSStreamEventHasBytesAvailable: {
            NSInteger       bytesRead;
            uint8_t         buffer[32768];

            [self updateStatus:@"Receiving"];
            
            // Pull some data off the network.
            
            bytesRead = [self.networkStream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == -1) {
                [self stopReceiveWithStatus:@"Network read error"];
            } else if (bytesRead == 0) {
                [self stopReceiveWithStatus:nil];
            } else {
                NSInteger   bytesWritten;
                NSInteger   bytesWrittenSoFar;
                
                // Write to the file.
                
                bytesWrittenSoFar = 0;
                do {
                    bytesWritten = [self.fileStream write:&buffer[bytesWrittenSoFar] maxLength:(NSUInteger) (bytesRead - bytesWrittenSoFar)];
                    assert(bytesWritten != 0);
                    if (bytesWritten == -1) {
                        [self stopReceiveWithStatus:@"File write error"];
                        break;
                    } else {
                        bytesWrittenSoFar += bytesWritten;
                    }
                } while (bytesWrittenSoFar != bytesRead);
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventErrorOccurred: {
            [self stopReceiveWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

#pragma mark * UI Actions

- (IBAction)getOrCancelAction:(id)sender
{
    #pragma unused(sender)
    if (self.isReceiving) {
        [self stopReceiveWithStatus:@"Cancelled"];
    } else {
        [self startReceive];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
    // A delegate method called by the URL text field when the editing is complete. 
    // We save the current value of the field in our settings.
{
    #pragma unused(textField)
    NSString *  newValue;
    NSString *  oldValue;
    
    assert(textField == self.urlText);

    newValue = self.urlText.text;
    oldValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"GetURLText"];

    // Save the URL text if it's changed.
    
    assert(newValue != nil);        // what is UITextField thinking!?!
    assert(oldValue != nil);        // because we registered a default
    
    if ( ! [newValue isEqual:oldValue] ) {
        [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:@"GetURLText"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
    // A delegate method called by the URL text field when the user taps the Return 
    // key.  We just dismiss the keyboard.
{
    #pragma unused(textField)
    assert(textField == self.urlText);
    [self.urlText resignFirstResponder];
    return NO;
}

#pragma mark * View controller boilerplate

- (void)viewDidLoad
{    
    [super viewDidLoad];

    assert(self.urlText != nil);
    assert(self.imageView != nil);
    assert(self.statusLabel != nil);
    assert(self.activityIndicator != nil);
    assert(self.getOrCancelButton != nil);
    
    self.getOrCancelButton.possibleTitles = [NSSet setWithObjects:@"Get", @"Cancel", nil];

    self.urlText.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"GetURLText"];
    
    self.activityIndicator.hidden = YES;
    self.statusLabel.text = @"Tap Get to start getting";
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.urlText = nil;
    self.imageView = nil;
    self.statusLabel = nil;
    self.activityIndicator = nil;
    self.getOrCancelButton = nil;
}

- (void)dealloc
{
    [self stopReceiveWithStatus:@"Stopped"];
}

@end