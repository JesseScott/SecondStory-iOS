//
//  MenuViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "MenuViewController.h"

#pragma mark - CONSTANTS -


#pragma mark - INTERFACE -

@interface MenuViewController ()

@property (weak, nonatomic) UIFont *buttonFont;
@property (weak, nonatomic) UIFont *liveFont;

@property (weak, nonatomic) IBOutlet UIButton *guideBtn;
@property (weak, nonatomic) IBOutlet UIButton *mapsBtn;
@property (weak, nonatomic) IBOutlet UIButton *aboutBtn;
@property (weak, nonatomic) IBOutlet UIButton *feedBtn;
@property (weak, nonatomic) IBOutlet UIButton *liveBtn;

@end

#pragma mark - IMPLEMENTATION -

@implementation MenuViewController


#pragma mark - LIFECYCLE -

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Font
    _buttonFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    _liveFont = [UIFont fontWithName:@"Din Alternate Black" size:32];

    // Buttons
    [_guideBtn.titleLabel setFont:_buttonFont];
    [_mapsBtn.titleLabel setFont:_buttonFont];
    [_aboutBtn.titleLabel setFont:_buttonFont];
    [_feedBtn.titleLabel setFont:_buttonFont];
    [_liveBtn.titleLabel setFont:_liveFont];
    
}


- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}



@end
