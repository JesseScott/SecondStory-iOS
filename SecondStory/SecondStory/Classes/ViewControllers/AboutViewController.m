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
