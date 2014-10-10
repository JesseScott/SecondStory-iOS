//
//  MapsViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "MapsViewController.h"


@implementation MapsViewController

@synthesize beefButton;
@synthesize penniesButton;
@synthesize sweepingButton;
@synthesize copperButton;
@synthesize macrameButton;
@synthesize umbrellasButton;
@synthesize alleyButton;
@synthesize bikeButton;
@synthesize gunButton;

@synthesize videoView;
@synthesize backgroundView;
@synthesize tap;

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
    [self.navigationController.navigationBar setBackgroundColor:bgColor];
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];

    // Hide Video View
    [self.view addSubview:self.videoView];
    [self.videoView setHidden:YES];
    
    // Set Playback State
    movieIsPlaying = NO;
    
    // Tap
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];

}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [moviePlayer stop];
    [self.videoView setHidden:YES];
}


- (void)LoadVideo: (NSURL*) videoUrl {
    
    // Show View
    [self.videoView setHidden:NO];
    
    //Set Player
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
    
    //Set Frame
    moviePlayer.view.frame = CGRectMake(40, 203, 240, 128);
    [self.view addSubview:[moviePlayer view]];
    
    // Controls
    moviePlayer.controlStyle = MPMovieControlStyleDefault;
    
    // Loop Video
    moviePlayer.repeatMode = MPMovieRepeatModeNone;
    
    // Play
    [moviePlayer play];
    
    // Finish
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name: MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    
}

- (void)playbackFinished {
    // Hide Video View
    [self.videoView setHidden:YES];
}


- (IBAction)clickedBeef:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"beef" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
    else {
        [moviePlayer stop];
        self.videoView.hidden = YES;
    }
}

- (IBAction)clickedPennies:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"pennies" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
    else {
        [moviePlayer stop];
        self.videoView.hidden = YES;
    }
}

- (IBAction)clickedSweeping:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"sweeping" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
    else {
        [moviePlayer stop];
        self.videoView.hidden = YES;
    }
}

- (IBAction)clickedCopper:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"copper" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
    else {
        [moviePlayer stop];
        self.videoView.hidden = YES;
    }
}

- (IBAction)clickedMacrame:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"shrooms" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
    else {
        [moviePlayer stop];
        self.videoView.hidden = YES;
    }
}

- (IBAction)clickedUmbrellas:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"umbrellas" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
}

- (IBAction)clickedAlley:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"bloodalley" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
}

- (IBAction)clickedBike:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"bicycles" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
    else {
        [moviePlayer stop];
        self.videoView.hidden = YES;
    }
}

- (IBAction)clickedGun:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"gun" withExtension:@"mp4"];
        [self LoadVideo:url];
    }
    else {
        [moviePlayer stop];
        self.videoView.hidden = YES;
    }
}

- (IBAction)tapped:(id)sender {
    //NSLog(@"TAPPED IBA");
}


@end
