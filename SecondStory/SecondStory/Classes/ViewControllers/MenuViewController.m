//
//  MenuViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "MenuViewController.h"


@implementation MenuViewController

@synthesize guideBtn, mapsBtn, aboutBtn, feedBtn, liveBtn;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Font
    buttonFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    liveFont = [UIFont fontWithName:@"Din Alternate Black" size:32];
    
    // Colors
    UIColor *buttonBgColor = [UIColor colorWithRed:(255/255.0f) green:(255/255.0f) blue:(204/255.0f) alpha:(204/255.0f)];
    UIColor *buttonTextColor = [UIColor colorWithRed:(5/255.0f) green:(5/255.0f) blue:(5/255.0f) alpha:(204/255.0f)];

    
    // Buttons
    [guideBtn.titleLabel setFont:buttonFont];
    [guideBtn.titleLabel setTextColor:buttonTextColor];
    [guideBtn setBackgroundColor:buttonBgColor];
    
    [mapsBtn.titleLabel setFont:buttonFont];
    [mapsBtn.titleLabel setTextColor:buttonTextColor];
    [mapsBtn setBackgroundColor:buttonBgColor];
    
    [aboutBtn.titleLabel setFont:buttonFont];
    [aboutBtn.titleLabel setTextColor:buttonTextColor];
    [aboutBtn setBackgroundColor:buttonBgColor];
    
    [feedBtn.titleLabel setFont:buttonFont];
    [feedBtn.titleLabel setTextColor:buttonTextColor];
    [feedBtn setBackgroundColor:buttonBgColor];
    
    [liveBtn.titleLabel setFont:liveFont];
    
}


- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
}

@end
