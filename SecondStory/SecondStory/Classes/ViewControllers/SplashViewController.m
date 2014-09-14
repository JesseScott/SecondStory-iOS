//
//  SplashViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "SplashViewController.h"


@implementation SplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Timer
    if(self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(segue) userInfo:nil repeats:NO];
    }
    
    // Nav Bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    
}

- (void) segue
{
    // Segue
    [self performSegueWithIdentifier:@"segue_splash2menu" sender:self];
    
    // Kill Timer
    self.timer = nil;
}

@end
