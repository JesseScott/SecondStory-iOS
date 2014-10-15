//
//  WelcomeViewController.h
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WhiteRaccoon.h"
#import "AssetsLibrary/AssetsLibrary.h"

@interface WelcomeViewController : UIViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate> {
    NSString *LOCAL_MEDIA_PATH;
    NSArray  *REMOTE_MEDIA_LIST;
    NSString *REMOTE_MEDIA_PATH;
    NSURLSessionConfiguration *backgroundConfigObject;
    NSURLSessionConfiguration *defaultConfigObject;
    NSURLSessionConfiguration *ephemeralConfigObject;
}

@property NSURLSession *backgroundSession;
@property NSURLSession *defaultSession;
@property NSURLSession *ephemeralSession;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@end
