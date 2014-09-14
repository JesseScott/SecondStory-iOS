//
//  GuideViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "GuideViewController.h"



@implementation GuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Nav Bar
    //self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor
                                                      colorWithRed:(106/255.f)
                                                      green:(108/255.f)
                                                      blue:(89/255.f)
                                                      alpha:(255/255.f)];
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
