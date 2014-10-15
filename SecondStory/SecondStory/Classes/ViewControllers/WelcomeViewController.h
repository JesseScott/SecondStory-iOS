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

@interface WelcomeViewController : UIViewController {
    NSString *MEDIA_PATH;
    uint64_t NECESSARY_SPACE;
    uint64_t AVAILABLE_SPACE;
}

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;



@end
