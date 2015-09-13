//
//  MenuViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark - INTERFACE -

@interface MenuViewController ()

@property (weak, nonatomic) UIFont *mFont;

@property (weak, nonatomic) IBOutlet UIButton *liveBtn;
@property (weak, nonatomic) IBOutlet UIButton *galleryBtn;
@property (weak, nonatomic) IBOutlet UIButton *creditsBtn;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;

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
    
     NSLog(@" --- MENU ---- ");
    
    // Font
    self.mFont = [UIFont fontWithName:@"Din Alternate Medium" size:24];

    
    // Buttons
    
    [_liveBtn.titleLabel setFont:_mFont];
    _liveBtn.layer.borderWidth = 3.0f;
    _liveBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [_galleryBtn.titleLabel setFont:_mFont];
    _galleryBtn.layer.borderWidth = 3.0f;
    _galleryBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [_creditsBtn.titleLabel setFont:_mFont];
    _creditsBtn.layer.borderWidth = 3.0f;
    _creditsBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [_feedbackBtn.titleLabel setFont:_mFont];
    _feedbackBtn.layer.borderWidth = 3.0f;
    _feedbackBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    
}


- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}



@end
