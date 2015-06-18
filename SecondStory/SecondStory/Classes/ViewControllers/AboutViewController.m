//
//  AboutViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "AboutViewController.h"


#pragma mark - CONSTANTS -



#pragma mark - INTERFACE -

@interface AboutViewController ()

@property NSInteger swipeCount;

@property (weak, nonatomic) IBOutlet UIImageView *slideshow;
@property (copy,nonatomic) NSArray *slides;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipe;


@end


#pragma mark - IMPLEMENTATION -


@implementation AboutViewController


#pragma mark - LIFECYCLE -


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load Images
    self.slides = [[NSArray alloc] init];
    self.slides = [NSArray arrayWithObjects:
                        [UIImage imageNamed:@"about_pg1"],
                        [UIImage imageNamed:@"about_pg2"],
                        [UIImage imageNamed:@"about_pg3"],
                        [UIImage imageNamed:@"about_pg4"],
                   nil];
    
    // Load Array
    _swipeCount = 0;
    [_slideshow setImage:[self.slides objectAtIndex:_swipeCount]];
    
    // Add Swipe Detection
    [self.view addGestureRecognizer:self.leftSwipe];
    [self.leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:self.rightSwipe];
    [self.rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];

}

- (void) viewWillAppear:(BOOL)animated {
    // Colours
    UIColor *bgColor = [UIColor colorWithRed:(51/255.0f) green:(51/255.0f) blue:(51/255.0f) alpha:(165/255.0f)];
    UIColor *fontColor = [UIColor colorWithRed:(213/255.0f) green:(220/255.0f) blue:(225/255.0f) alpha:(255/255.0f)];
    
    // Font
    UIFont *navFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: fontColor, NSForegroundColorAttributeName, navFont, NSFontAttributeName, nil];
    
    // Nav Bar
    self.navigationController.navigationBar.tintColor = fontColor;
    [self.navigationController.navigationBar setBackgroundColor:bgColor];
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
}


#pragma mark - ACTIONS -


- (IBAction)previousImage:(UISwipeGestureRecognizer *)sender {
    if(_swipeCount > 0) {
        _swipeCount = _swipeCount - 1;
        [_slideshow setImage:[self.slides objectAtIndex:_swipeCount]];
    }
}

- (IBAction)nextImage:(UISwipeGestureRecognizer *)sender {
    if(_swipeCount < self.slides.count - 1) {
        _swipeCount = _swipeCount + 1;
        [_slideshow setImage:[self.slides objectAtIndex:_swipeCount]];
    }
}



@end
