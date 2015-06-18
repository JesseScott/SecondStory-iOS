//
//  SplashViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "SplashViewController.h"

#pragma mark - INTERFACE -


@interface SplashViewController ()

@property (nonatomic, weak) UIFont *labelFont;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, strong) NSTimer *timer;

@end

#pragma mark - IMPLEMENTATION -


@implementation SplashViewController


#pragma mark - LIFECYCLE -

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if(_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(segue) userInfo:nil repeats:NO];
    }
    
    _labelFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    _label.font = _labelFont;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - SEGUE -


- (void) segue
{
    [self performSegueWithIdentifier:@"segue_splash2welcome" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue_splash2welcome"]) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
