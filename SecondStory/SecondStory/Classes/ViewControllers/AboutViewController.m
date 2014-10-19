//
//  AboutViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

@synthesize slideshow;
@synthesize slides;
@synthesize leftSwipe, rightSwipe;

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
    swipeCount = 0;
    [slideshow setImage:[self.slides objectAtIndex:swipeCount]];
    
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

- (IBAction)previousImage:(UISwipeGestureRecognizer *)sender {
    if(swipeCount > 0) {
        
        // Set Index
        swipeCount = swipeCount - 1;
        
        // Set Image
        [slideshow setImage:[self.slides objectAtIndex:swipeCount]];
    }

}

- (IBAction)nextImage:(UISwipeGestureRecognizer *)sender {
    if(swipeCount < self.slides.count - 1) {
        
        // Set Index
        swipeCount = swipeCount + 1;
        
        // Set Image
        [slideshow setImage:[self.slides objectAtIndex:swipeCount]];
    }
}



@end
