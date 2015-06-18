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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Font
    _buttonFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    _liveFont = [UIFont fontWithName:@"Din Alternate Black" size:32];
    
    // Colors
    UIColor *buttonBgColor = [UIColor colorWithRed:(255/255.0f) green:(255/255.0f) blue:(204/255.0f) alpha:(204/255.0f)];
    UIColor *buttonTextColor = [UIColor colorWithRed:(5/255.0f) green:(5/255.0f) blue:(5/255.0f) alpha:(204/255.0f)];

    // Buttons
    [_guideBtn.titleLabel setFont:_buttonFont];
    [_guideBtn.titleLabel setTextColor:buttonTextColor];
    [_guideBtn setBackgroundColor:buttonBgColor];
    
    [_mapsBtn.titleLabel setFont:_buttonFont];
    [_mapsBtn.titleLabel setTextColor:buttonTextColor];
    [_mapsBtn setBackgroundColor:buttonBgColor];
    
    [_aboutBtn.titleLabel setFont:_buttonFont];
    [_aboutBtn.titleLabel setTextColor:buttonTextColor];
    [_aboutBtn setBackgroundColor:buttonBgColor];
    
    [_feedBtn.titleLabel setFont:_buttonFont];
    [_feedBtn.titleLabel setTextColor:buttonTextColor];
    [_feedBtn setBackgroundColor:buttonBgColor];
    
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
