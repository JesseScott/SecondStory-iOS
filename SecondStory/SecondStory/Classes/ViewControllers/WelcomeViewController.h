//
//  WelcomeViewController.h
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate> {
    
    NSString *LOCAL_MEDIA_PATH;
    NSString *REMOTE_MEDIA_PATH;
    
    NSArray  *REMOTE_MEDIA_FILE_PATHS;

    NSArray  *NSURL_BACKGROUND_SESSIONS;
    NSArray  *NSURL_BACKGROUND_CONFIGURATIONS;
    NSURLSessionConfiguration *backgroundConfigObject;
    int downloadsSuccessfulCounter;
}

@property NSURLSession *backgroundSession;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@end
