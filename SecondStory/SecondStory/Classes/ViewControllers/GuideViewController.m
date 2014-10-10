//
//  GuideViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "GuideViewController.h"



@implementation GuideViewController

@synthesize replayBtn;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Colours
    UIColor *bgColor = [UIColor colorWithRed:(51/255.0f) green:(51/255.0f) blue:(51/255.0f) alpha:(204/255.0f)];
    UIColor *fontColor = [UIColor colorWithRed:(255/255.0f) green:(255/255.0f) blue:(204/255.0f) alpha:(204/255.0f)];

    // Font
    UIFont *navFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: fontColor, NSForegroundColorAttributeName, navFont, NSFontAttributeName, nil];
    
    // Nav Bar
    self.navigationController.navigationBar.tintColor = fontColor;
    self.replayBtn.tintColor = fontColor;
    [self.navigationController.navigationBar setBackgroundColor:bgColor];
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
    
    // Audio
    [self performSelector:@selector(playAudio) withObject:self afterDelay:2.0];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [player stop];
}

- (void) playAudio {
    NSURL *soundFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"guide" ofType:@"mp3"]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops = 0;
    [player setCurrentTime:0.0];
    [player play];
}


- (IBAction)replayAudio:(id)sender {
    [self playAudio];
}


@end
