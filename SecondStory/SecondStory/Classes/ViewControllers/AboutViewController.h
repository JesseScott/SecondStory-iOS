//
//  AboutViewController.h
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController {
    
    NSInteger swipeCount;
    
}

// Image View
@property (weak, nonatomic) IBOutlet UIImageView *slideshow;
@property (copy,nonatomic) NSArray *slides;

// Swipe
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipe;

- (IBAction)previousImage:(UISwipeGestureRecognizer *)sender;
- (IBAction)nextImage:(UISwipeGestureRecognizer *)sender;

@end
