//
//  SSMoviePlayerController.m
//  SecondStory
//
//  Created by Jesse Scott on 2015-09-06.
//  Copyright (c) 2015 The Only Animal. All rights reserved.
//

#import "SSMoviePlayerController.h"


@interface SSMoviePlayerController ()

@end

@implementation SSMoviePlayerController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end