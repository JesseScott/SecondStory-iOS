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
    NSArray  *REMOTE_MEDIA_LIST;
    NSString *REMOTE_MEDIA_PATH;
    NSURLSessionConfiguration *backgroundConfigObject;
}

@property NSURLSession *backgroundSession;
@property (nonatomic) int downloadsSuccessfulCounter;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@end
