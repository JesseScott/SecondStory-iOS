//
//  SplashViewController.h
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController {
    
    // Font
    UIFont *labelFont;

}

@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
