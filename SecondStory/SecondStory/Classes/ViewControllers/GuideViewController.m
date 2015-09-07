//
//  GuideViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "GuideViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - CONSTANTS -


#pragma mark - INTERFACE -

@interface GuideViewController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *replayBtn;

@end

#pragma mark - IMPLEMENTATION -

@implementation GuideViewController


#pragma mark - LIFECYCLE -


- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Audio
    [self performSelector:@selector(playAudio) withObject:self afterDelay:2.0];

    
    // Lifecycle
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseAudio) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeAudio) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    // Colours
    UIColor *bgColor = [UIColor colorWithRed:(51/255.0f) green:(51/255.0f) blue:(51/255.0f) alpha:(164/255.0f)];
    UIColor *fontColor = [UIColor colorWithRed:(255/255.0f) green:(255/255.0f) blue:(204/255.0f) alpha:(204/255.0f)];

    // Font
    UIFont *navFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: fontColor, NSForegroundColorAttributeName, navFont, NSFontAttributeName, nil];
    
    // Nav Bar
    self.navigationController.navigationBar.tintColor = fontColor;
    [self.navigationController.navigationBar setBackgroundColor:bgColor];
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
}

- (void) viewWillDisappear:(BOOL)animated {
    [_player stop];
    _player = nil;
    _replayBtn = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - AUDIO -

- (void) playAudio
{
    NSURL *soundFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"guide" ofType:@"mp3"]];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    _player.numberOfLoops = 0;
    [_player setCurrentTime:0.0];
    [_player play];
}


- (void) pauseAudio
{
    //NSLog(@"PAUSE");
    if (_player != nil) {
        [_player pause];
    }
}

- (void) resumeAudio
{
    //NSLog(@"RESUME");
    if (_player != nil) {
        [_player play];
    }
}

- (IBAction)replayAudio:(id)sender
{
    [self playAudio];
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"DONE");
}


@end
