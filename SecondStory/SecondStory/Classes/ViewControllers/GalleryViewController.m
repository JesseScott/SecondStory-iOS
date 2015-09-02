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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;


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
    
    imageArray = [NSArray arrayWithObjects:
                   [UIImage imageNamed:@"amy.jpg"],
                   [UIImage imageNamed:@"claire.jpg"],
                   [UIImage imageNamed:@"jess.jpg"],
                   [UIImage imageNamed:@"kiki.jpg"],
                   [UIImage imageNamed:@"marci.jpg"],
                   [UIImage imageNamed:@"mily.jpg"],
                   [UIImage imageNamed:@"sultan.jpg"],
                   nil];
    
    [_imageView setImage:[imageArray objectAtIndex:currentIndex]];

    titleArray = [NSArray arrayWithObjects:
                  @"Cirque Dystopic",
                  @"Exhibit A",
                  @"Leaving the House",
                  @"A Letter Too Late Pt1",
                  @"A Letter Too Late Pt2",
                  @"Plant",
                  @"Portability",
                  @"Stall 43",
                  nil];
    
    self.titleLabel.text = [titleArray objectAtIndex:currentIndex];
    
    artistArray = [NSArray arrayWithObjects:
                  @"Milly Mumford",
                  @"Claire Love Wilson",
                  @"Amy Dauer",
                  @"Sultan Owaisi",
                  @"Sultan Owaisi",
                  @"Marcela Amaya",
                  @"Jess Amy Shead",
                  @"Baraka Ramini",
                  nil];
    
    self.artistLabel.text = [artistArray objectAtIndex:currentIndex];

    
}

#pragma mark - ACTIONS -

-(void)swipeLeft:(UISwipeGestureRecognizer *)recognizer {
    if (currentIndex < [imageArray count] -1) {
        currentIndex++;
        [_imageView setImage:[imageArray objectAtIndex:currentIndex]];
        self.titleLabel.text = [titleArray objectAtIndex:currentIndex];
        self.artistLabel.text = [artistArray objectAtIndex:currentIndex];
    }
}

-(void)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    if(currentIndex > 0) {
        currentIndex--;
        [_imageView setImage:[imageArray objectAtIndex:currentIndex]];
        self.titleLabel.text = [titleArray objectAtIndex:currentIndex];
        self.artistLabel.text = [artistArray objectAtIndex:currentIndex];
    }
}




@end
