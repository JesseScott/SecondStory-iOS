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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Nav Bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    // Font
    buttonFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    liveFont = [UIFont fontWithName:@"Din Alternate Black" size:32];
    
    [guideBtn.titleLabel setFont:buttonFont];
    [mapsBtn.titleLabel setFont:buttonFont];
    [aboutBtn.titleLabel setFont:buttonFont];
    [feedBtn.titleLabel setFont:buttonFont];
    
    [liveBtn.titleLabel setFont:liveFont];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
