//
//  WelcomeViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "WelcomeViewController.h"

//
#define MB (1024*1024)
#define GB (MB*1024)

@implementation WelcomeViewController

#pragma mark SYNTHESIZE

// Synthesize
@synthesize assetsLibrary;
@synthesize backgroundSession, defaultSession, ephemeralSession;

#pragma mark VIEW

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // PATHS
    LOCAL_MEDIA_PATH = @"/SecondStory/BloodAlley/MEDIA";
    REMOTE_MEDIA_PATH = @"http://jesses.co.tt/projects/second_story/blood_alley/media/";
    
    // CHECK
    if ([self checkForContent]) {
        [self segue];
    }
    else {
        [self showStreamOrDownloadDialog];
    }
    
    // SESSION
    [self setupURLSessions];
    
}

- (void) segue {
    [self performSegueWithIdentifier:@"segue_welcome2menu" sender:self];
}

#pragma mark ALERTS

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
                                                    message:@"this app requires 500mb of space in order to download the content"
                                                   delegate:self
                                          cancelButtonTitle:@":("
                                          otherButtonTitles:nil];
    alert.tag = 200;
    [alert show];
}
                                              
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if(buttonIndex == 0) { // Stream
            [self segue];
        }
        else if(buttonIndex == 1) { // Download
            [self prepDownload];
        }
    }
}


#pragma mark DIR

- (BOOL) checkForContent {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:LOCAL_MEDIA_PATH];
    BOOL isDir;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath isDirectory:&isDir]) {
        if (isDir) {
            NSLog(@"DIRECTORY EXISTS - TRYING TO READ CONTENTS");
            NSError *error = nil;
            NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:&error];
            if (error == nil) {
                NSInteger files = [contents count];
                if (files > 0) {
                    NSLog(@"DIRECTORY HAS %i FILES", [contents count]);
                    return YES;
                }
                else {
                    NSLog(@"NO FILES EXIST");
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

- (void) setupURLSessions {
    backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: @"SecondStoryBackgroundSessionIdentifier"];
    defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    ephemeralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    NSString *cachePath = @"/MyCacheDirectory";
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
    NSLog(@"CACHE PATH: %@\n", fullCachePath);
    NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity: 16384 diskCapacity: 268435456 diskPath: cachePath];
    defaultConfigObject.URLCache = myCache;
    defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    self.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    self.backgroundSession = [NSURLSession sessionWithConfiguration: backgroundConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    self.ephemeralSession = [NSURLSession sessionWithConfiguration: ephemeralConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
}


- (void) prepDownload {
    if ([self checkForSpace]) {
        NSLog(@"HAVE SPACE : CHECKING DIRECTORY");
        if ([self createCustomDirectory]) {
            NSLog(@"HACE DIRECTORY : STARTING DOWNLOAD");
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
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    [[delegateFreeSession dataTaskWithURL:[NSURL URLWithString:list]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSLog(@"Got response %@ with error %@.\n", response, error);
                
                NSString *stringFromData = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog(@"DATA:\n%@\nEND DATA\n", stringFromData);
                
                REMOTE_MEDIA_LIST = [stringFromData componentsSeparatedByString:@"\n"];
                NSLog(@"THERE ARE %i MEDIA FILES", [REMOTE_MEDIA_LIST count]);
                for (int i = 0; i < [REMOTE_MEDIA_LIST count]; i++) {
                    NSLog(@"FILE %i IS %@", i, [REMOTE_MEDIA_LIST objectAtIndex:i]);
                }
                [self getFile:[REMOTE_MEDIA_LIST objectAtIndex:0]];
            }]
     resume];
}

- (void) getFile : (NSString*) file {
    NSLog(@"PASSED FILE IS %@", file);
    NSString *fullPathToFile = REMOTE_MEDIA_PATH;
    fullPathToFile = [fullPathToFile stringByAppendingString:file];
    NSLog(@"FULL PATH IS %@", fullPathToFile);
    
    NSURL *url = [NSURL URLWithString:fullPathToFile];
    NSURLSessionDownloadTask *downloadTask = [self.backgroundSession downloadTaskWithURL: url];
    [downloadTask resume];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Session %@ download task %@ finished downloading to URL %@\n", session, downloadTask, location);
    
    // Get the documents directory URL
    NSURL *customDirectory = [[NSURL alloc] initWithString:LOCAL_MEDIA_PATH];
    
    // Get the file name and create a destination URL
    NSString *sendingFileName = [downloadTask.originalRequest.URL lastPathComponent];
    NSURL *destinationUrl = [customDirectory URLByAppendingPathComponent:sendingFileName];
    
    // Hold this file as an NSData and write it to the new location
    NSData *fileData = [NSData dataWithContentsOfURL:location];
    [fileData writeToURL:destinationUrl atomically:NO];
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"Session %@ download task %@ wrote an additional %lld bytes (total %lld bytes) out of an expected %lld bytes.\n",
          session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
          session, downloadTask, fileOffset, expectedTotalBytes);
}





@end
