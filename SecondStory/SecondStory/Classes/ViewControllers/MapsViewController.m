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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Hide Video View
    self.videoView.hidden = YES;
    
    // Set Playback State
    movieIsPlaying = NO;

}


- (void)LoadVideo: (NSURL*) videoUrl {
    NSLog(@"LOAD");
    
    //Set Url
    //NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"sitStand" withExtension:@"m4v"];
    
    //Set Player
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
    
    //Set Frame
    //[[moviePlayer view] setFrame:[self.videoView bounds]];
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
    NSLog(@"DONE");
}


- (IBAction)clickedBeef:(id)sender {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"sitStand" withExtension:@"m4v"];
}

- (IBAction)clickedPennies:(id)sender {
    
}

- (IBAction)clickedSweeping:(id)sender {
    
}

- (IBAction)clickedCopper:(id)sender {
    
}

- (IBAction)clickedMacrame:(id)sender {
    
}

- (IBAction)clickedUmbrellas:(id)sender {
    
}

- (IBAction)clickedAlley:(id)sender {
    
}

- (IBAction)clickedBike:(id)sender {
    
}

- (IBAction)clickedGun:(id)sender {
    
}


@end
