//
//  SplashViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "SplashViewController.h"


@implementation SplashViewController

@synthesize label;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Timer
    if(self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(segue) userInfo:nil repeats:NO];
    }
    
    // Font
    labelFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    label.font = labelFont;
    
}

- (void) segue
{
    // Segue
    [self performSegueWithIdentifier:@"segue_splash2menu" sender:self];
    
    // Kill Timer
    self.timer = nil;
}

@end
