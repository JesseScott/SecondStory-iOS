//
//  GalleryViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2015-07-29.
//  Copyright (c) 2015 The Only Animal. All rights reserved.
//

#import "GalleryViewController.h"


#pragma mark - CONSTANTS -

#pragma mark - INTERFACE -

@interface GalleryViewController ()  <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwiperecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@end

#pragma mark - IMPLEMENTATION -

@implementation GalleryViewController

#pragma mark - LIFECYCLE -

- (void)viewDidLoad {
    [super viewDidLoad];

    currentIndex = 0;
    
    _leftSwiperecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    _leftSwiperecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftSwiperecognizer.delegate = self;
    [self.view addGestureRecognizer:_leftSwiperecognizer];
    
    _rightSwipRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    _rightSwipRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    _rightSwipRecognizer.delegate = self;
    [self.view addGestureRecognizer:_rightSwipRecognizer];

}

#pragma mark - ACTIONS -

-(void)swipeLeft:(UISwipeGestureRecognizer *)recognizer {
    currentIndex++;
    [_countLabel setText:[NSString stringWithFormat:@"%i", currentIndex]];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    if(currentIndex > 0) {
        currentIndex--;
        [_countLabel setText:[NSString stringWithFormat:@"%i", currentIndex]];
    }
}




@end
