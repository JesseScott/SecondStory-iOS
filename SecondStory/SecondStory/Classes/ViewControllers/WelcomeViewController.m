//
//  WelcomeViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "WelcomeViewController.h"


@implementation WelcomeViewController

#pragma mark SYNTHESIZE

// Synthesize
@synthesize remote_label;

#pragma mark VIEW

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Check For File
    NSString *path = [[NSBundle mainBundle] pathForResource:@"media_list" ofType:@"txt"];
    if (path) {
        NSLog(@"File is in bundle");
    }
    else {
        NSLog(@"Unable to find file in bundle");
        //[self beginFTPOperation];
        //[self listDirectoryContents];
    }
}

#pragma mark FTP

- (void) beginFTPOperation
{
    // Init
    WRRequestDownload *downloadFile = [[WRRequestDownload alloc] init];
    downloadFile.delegate = self;
    
    // Path
    //downloadFile.path = @"ftp://nssdcftp.gsfc.nasa.gov/photo_gallery/image/spacecraft/pioneer10-11.jpg";
    //downloadFile.path = @"ftp://ghostlight:gh0st_l1ght@ftp.memelab.ca/public_html/jessescott/storage/android/beef.mp4";
    //downloadFile.path = @"ftp://ftp.memelab.ca/media_list.txt";
    downloadFile.path = @"ftp://memelab@ftp.memelab.ca/public_html/jessescott/projects/second_story/blood_alley/settings/media_list.txt";
    
    // Login
    downloadFile.hostname = @"ftp.memelab.ca";
    downloadFile.username = @"memelab";
    downloadFile.password = @"B1cycl5!";
    
    // Start
    [downloadFile start];
}

- (void) listDirectoryContents
{
    WRRequestListDirectory *listDir = [[WRRequestListDirectory alloc] init];
    listDir.delegate = self;
    
    //full URL would be ftp://xxx.xxx.xxx.xxx/
    listDir.path = @"ftp://memelab@ftp.memelab.ca/";

    listDir.hostname = @"ftp.memelab.ca";
    listDir.username = @"memelab";
    listDir.password = @"B1cycl5!";
    
    [listDir start];
}

-(void) requestCompleted:(WRRequest *) request{
    NSLog(@"%@ Completed! ", request);
    
    //Cast
    WRRequestDownload *downloadFile = (WRRequestDownload *)request;
    
    // Get Data
    NSString *str = [[NSString alloc] initWithData:downloadFile.receivedData encoding:NSUTF8StringEncoding];
    //remote_label.text = str;
}

-(void) requestFailed:(WRRequest *) request{
    NSLog(@"FAIL: %@", request.error.message);
}

#pragma mark SEGUE

- (void) segue
{
    // Segue
    [self performSegueWithIdentifier:@"segue_welcome2camera" sender:self];
}


- (IBAction)skip:(id)sender {
    [self segue];
}

@end
