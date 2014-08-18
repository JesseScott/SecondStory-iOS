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
    
    
}

- (void) segue
{
    // Segue
    [self performSegueWithIdentifier:@"segue_splash2welcome" sender:self];
    
    // Kill Timer
    self.timer = nil;
}

@end
