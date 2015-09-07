//
//  WelcomeViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "WelcomeViewController.h"

#pragma mark - CONSTANTS -

#define MB (1024*1024)
#define GB (MB*1024)
#define LOCAL_MEDIA_PATH  @"/SecondStory/BloodAlley/MEDIA"
#define REMOTE_MEDIA_PATH @"http://jesses.co.tt/projects/second_story/blood_alley/media/"

#pragma mark - INTERFACE -

@interface WelcomeViewController ()

@property NSURLSession *backgroundSession;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

#pragma mark - IMPLEMENTATION -

@implementation WelcomeViewController


#pragma mark - LIFECYCLE -

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.progressView setHidden:YES];
    [self.skipButton setHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    // PATHS

    
    // CHECK
    if ([self checkForContent]) {
        [self segue];
    }
    else {
        [self showStreamOrDownloadDialog];
    }
    
    // Counter
    downloadCounter = 0;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Nil Stuff
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil)
    {
        self.view = nil;
    }
}

#pragma mark - SEGUE -

- (void) segue {
    [self performSegueWithIdentifier:@"segue_welcome2menu" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Kill Stuff
}


    



#pragma mark - ALERTS - 

- (void) showStreamOrDownloadDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Content Doesn't Exist"
                                                    message:@"this app requires custom content - you can download it to your device or stream it."
                                                   delegate:self
                                          cancelButtonTitle:@"Stream"
                                          otherButtonTitles:@"Download",
                          nil];
    alert.tag = 100;
    [alert show];
}

- (void) showNotEnoughSpaceDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Space"
                                                    message:@"this app requires 500mb of space in order to download the content. You can skip for now and stream the content, or come back when you have enough space."
                                                   delegate:self
                                          cancelButtonTitle:@"Skip"
                                          otherButtonTitles:@"Quit",
                          nil];
    alert.tag = 200;
    [alert show];
}

- (void) showSkipOrWaitDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In Progress"
                                                    message:@"this app is currently downloading the content... feel free to press the skip button and it will continue in the background."
                                                   delegate:self
                                          cancelButtonTitle:@"Skip"
                                          otherButtonTitles:@"Wait",
                          nil];
    alert.tag = 300;
    [alert show];
}
                                              
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if(buttonIndex == 0) { // Stream
            [self segue];
        }
        else if(buttonIndex == 1) { // Download
            [self prepDownload];
            [self.skipButton setHidden:NO];
        }
    }
    else if (alertView.tag == 200) {
        if(buttonIndex == 0) { // Skip
            // Set Stream Defaults
            [self segue];
        }
        else if(buttonIndex == 1) { // Quit

        }
    }
    else if (alertView.tag == 300) {
        if(buttonIndex == 0) { // Skip
            [self segue];
        }
        else if(buttonIndex == 1) { // Wait
            [self.skipButton setHidden:NO];
            [self.progressView setHidden:NO];
        }
    }
}


- (IBAction)skip:(id)sender {
    [self segue];
}


#pragma mark - DIR -

- (NSString*) returnDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doc = [paths objectAtIndex:0];
    return doc;
}

- (BOOL) checkForContent {
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [[self returnDocumentsDirectory] stringByAppendingPathComponent:LOCAL_MEDIA_PATH];
    BOOL isDir;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath isDirectory:&isDir]) {
        if (isDir) {
            NSLog(@"DIRECTORY EXISTS - TRYING TO READ CONTENTS");
            NSError *error = nil;
            NSArray  *existing = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:&error];
            NSString *pathToLocalPlist = [[NSBundle mainBundle] pathForResource:@"bloodalley_filenames_local" ofType:@"plist"];
            NSArray  *matching = [[NSArray alloc] initWithContentsOfFile:pathToLocalPlist];
            if (error == nil) {
                if ([existing count] == [matching count]) {
                    NSLog(@"DIRECTORY HAS ALL THE FILES");
                    return YES;
                }
                else {
                    NSLog(@"ONLY %i FILES EXIST", [existing count]);
                    for (int i = 0; i < [existing count]; i++) {
                        NSLog(@"Local #%i is %@", i, [existing objectAtIndex:i]);
                        if( [[matching objectAtIndex:i] isEqualToString:[existing objectAtIndex:i]] ) {
                            NSLog(@"MATCH: %@ Exists", [existing objectAtIndex:i]);
                        }
                    }
                    int numFilesToGet = [matching count] - [existing count];
                    REMOTE_MEDIA_FILE_PATHS = [[NSMutableArray alloc] initWithCapacity:numFilesToGet];
                    for (int i = [existing count]; i < [matching count]; i++) {
                        [REMOTE_MEDIA_FILE_PATHS addObject:[matching objectAtIndex:i]];
                    }
                    return NO;
                }
            }
            else {
                NSLog(@"ERROR READING DIRECTORY: %@", error);
                return NO;
            }
        }
        else {
            NSLog(@"PATH EXISTS BUT ITS NOT A DIRECTORY");
            [self createCustomDirectory];
            return NO;
        }
    }
    else {
        NSLog(@"DIRECTORY DOESNT EXIST");
        [self createCustomDirectory];
        return NO;
    }
}

- (void) listCustomDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:LOCAL_MEDIA_PATH];

    NSError *error = nil;
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:&error];
    NSLog(@"DIRECTORY HAS %i FILES", [contents count]);
    for (int i = 0; i < [contents count]; i++) {
        NSLog(@"Item #%i is %@", i, [contents objectAtIndex:i]);
    }
}

- (BOOL) createCustomDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:LOCAL_MEDIA_PATH];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (error == nil) {
        return YES;
    }
    else {
        NSLog(@"Create Directory Error: %@", error);
        return NO;
    }
}

- (BOOL) checkForSpace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    double NEED;
    double HAVE;
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        
        NEED = 500.00;
        HAVE = ((totalFreeSpace/1024ll)/1024ll);
        
        //NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    if (HAVE >= NEED) {
        return YES;
    }
    else {
        return NO;
    }
    
    return totalFreeSpace;
}


#pragma mark NET

- (void) instantiateURLSessions : (int) size {
    
    NSMutableArray *configurations = [NSMutableArray array];
    NSMutableArray *sessions = [NSMutableArray array];
    
    for (int i = 0; i < size; i++) {
        NSString *index = [NSString stringWithFormat:@"%i", i];
        NSString *UniqueIdentifier = @"SecondStoryBackgroundSessionIdentifier_";
        UniqueIdentifier = [UniqueIdentifier stringByAppendingString:index];
        NSURLSessionConfiguration *config;
        if([[UIDevice currentDevice].systemVersion floatValue] >= 8)
        {
            config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:UniqueIdentifier];
        }
        else
        {
            config = [NSURLSessionConfiguration backgroundSessionConfiguration:UniqueIdentifier];
        }
        
        config.allowsCellularAccess = NO;
        [configurations addObject: config];
        [sessions addObject:[NSURLSession sessionWithConfiguration: [configurations objectAtIndex:i]  delegate: self delegateQueue: [NSOperationQueue mainQueue]]];
    }
    
    NSURL_BACKGROUND_CONFIGURATIONS = [NSArray arrayWithArray:configurations];
    NSURL_BACKGROUND_SESSIONS = [NSArray arrayWithArray:sessions];
}


- (void) prepDownload {
    if ([self checkForSpace]) {
        NSLog(@"HAVE SPACE : CHECKING DIRECTORY");
        if ([self createCustomDirectory]) {
            NSLog(@"HAVE DIRECTORY : STARTING DOWNLOAD");
            [self getMediaList];
        }
        else {
            NSLog(@"PROBLEM CREATING DIRECTORY");
        }
    }
    else {
        [self showNotEnoughSpaceDialog];
    }
}

- (void) getMediaList {

    NSString *list = @"http://jesses.co.tt/projects/second_story/blood_alley/settings/media_list.txt";
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:list]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if(!error) {
                    NSLog(@"Got response %@ with error %@.\n", response, error);
                    
                    //NSString *stringFromData = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                    //NSLog(@"DATA:\n%@\nEND DATA\n", stringFromData);
                    
                    // Populate Arrays
                    //REMOTE_MEDIA_FILE_PATHS = [stringFromData componentsSeparatedByString:@"\n"];
                    [self instantiateURLSessions:[REMOTE_MEDIA_FILE_PATHS count]];
                     
                    NSLog(@"THERE ARE %i MEDIA FILES", [REMOTE_MEDIA_FILE_PATHS count]);
                    for (int i = 0; i < [REMOTE_MEDIA_FILE_PATHS count]; i++) {
                        NSLog(@"FILE %i IS %@", i, [REMOTE_MEDIA_FILE_PATHS objectAtIndex:i]);
                    }
                    
                    // Start First File
                    [self getFile:[REMOTE_MEDIA_FILE_PATHS objectAtIndex:downloadCounter]:downloadCounter];
                }
                else {
                    NSLog(@"Error Fetching File List, Going With Local Version...");
                    // Load LocalPList For Files
                    //NSString *pathToLocalPlist = [[NSBundle mainBundle] pathForResource:@"bloodalley_filenames_local" ofType:@"plist"];
                    //REMOTE_MEDIA_FILE_PATHS = [[NSMutableArray alloc] initWithContentsOfFile:pathToLocalPlist];
                }
            }]
     resume];
    
    //[self.progressView setHidden:NO];
    [self showSkipOrWaitDialog];
}



- (void) getFile : (NSString*) file :(int) index {
    if (file != nil) {
        NSLog(@"PASSED FILE IS %@", file);
        NSString *fullPathToFile = REMOTE_MEDIA_PATH;
        fullPathToFile = [fullPathToFile stringByAppendingString:file];
        NSLog(@"FULL PATH IS %@ \n\n\n", fullPathToFile);

        NSURL *url = [NSURL URLWithString:fullPathToFile];
        NSURLSessionDownloadTask *downloadTask = [[NSURL_BACKGROUND_SESSIONS objectAtIndex:index ] downloadTaskWithURL: url];
        [downloadTask resume];
    }
    else {
        NSLog(@"Passed File Is NIL");
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Session %@ download task %@ finished downloading to URL %@\n", session, downloadTask, location);
    
    //[self.progressView setHidden:YES];
    
    // Get the documents directory URL
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:LOCAL_MEDIA_PATH];
    NSURL *customDirectory = [NSURL fileURLWithPath:dataPath];
    
    // Get the file name and create a destination URL
    NSString *sendingFileName = [downloadTask.originalRequest.URL lastPathComponent];
    NSURL *destinationUrl = [customDirectory URLByAppendingPathComponent:sendingFileName];
    
    // Move the file
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager moveItemAtURL:location toURL:destinationUrl error: &error]) {
        NSLog(@"Moving File To %@", destinationUrl);
        
        // List
        [self listCustomDirectory];
        
        if(downloadCounter < [REMOTE_MEDIA_FILE_PATHS count] -1) {
            // Increment Counter
            downloadCounter++;
            NSLog(@"\nREADY TO START FILE #%i \n", downloadCounter);
        
            // Start Next File
            [self getFile:[REMOTE_MEDIA_FILE_PATHS objectAtIndex:downloadCounter]:downloadCounter];
        }
        else {
            NSLog(@"ALL DONE !!");
            [self segue];
        }
    }
    else {
        NSLog(@"\n\n\nDamn. Error %@", error);
    }
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"Session %@ download task %@ wrote an additional %lld bytes (total %lld bytes) out of an expected %lld bytes.\n", session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress];
    });
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
          session, downloadTask, fileOffset, expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"SessionTask %@ gave error %@.\n", task, error);
}


@end
