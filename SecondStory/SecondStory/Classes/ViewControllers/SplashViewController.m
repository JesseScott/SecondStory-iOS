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

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void) segue
{
    // Segue
    [self performSegueWithIdentifier:@"segue_splash2welcome" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Kill Timer
    [self.timer invalidate];
    self.timer = nil;
}

@end
