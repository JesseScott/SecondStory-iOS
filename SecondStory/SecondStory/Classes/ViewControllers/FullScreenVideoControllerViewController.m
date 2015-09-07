//
//  FullScreenVideoControllerViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2015-09-06.
//  Copyright (c) 2015 The Only Animal. All rights reserved.
//

#import "FullScreenVideoControllerViewController.h"
#import <MediaPlayer/MediaPlayer.h>


@interface FullScreenVideoControllerViewController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property BOOL movieIsPlaying;
@property (nonatomic, weak) UIButton *backButton;

@end

@implementation FullScreenVideoControllerViewController

#pragma mark - LIFECYCLE -


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    //[[UIDevice currentDevice] setValue:value forKey:@"orientation"];

    CGFloat offset = self.view.frame.size.height - self.view.frame.size.width;
    self.view.transform = CGAffineTransformMakeRotation(90 * M_PI/180);
    self.view.frame = CGRectMake(-offset, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self initMoviePlayerWithIndex:self.currentIndex];
    
    [self addBackButton];
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}


-(void)addBackButton {
    _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _backButton.frame = CGRectMake(25.0, 25.0, 25.0, 25.0);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"global_back_icon"] forState:UIControlStateNormal];
    [self.view addSubview:_backButton];
}

- (void)backButtonPressed:(id)sender {
    [_moviePlayer stop];
    [self dismissViewControllerAnimated:NO completion:nil];
}


# pragma mark - VIDEO -


-(void)initMoviePlayerWithIndex:(NSInteger* )index {
    NSString *movie = [self getMoviePath:*index];
    if([movie length] > 0) {
        NSString *path = [[NSBundle mainBundle]pathForResource:movie ofType:@"mp4"];
        NSLog(@"Loading Asset: %@", path);
        [self loadVideo:[NSURL fileURLWithPath:path]];
    }
    else {
        NSLog(@"ERROR - failed to find movie by index");
    }
}

- (void)loadVideo: (NSURL *) videoUrl {
    
    // Alloc Player
    _moviePlayer = [[MPMoviePlayerController alloc] init];
    
    //Set URL
    [_moviePlayer setContentURL:videoUrl];
    
    //Set Frame
    _moviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:[_moviePlayer view]];
    
    // Controls
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    // Loop Video
    _moviePlayer.repeatMode = MPMovieRepeatModeNone;
    
    // Prepare
    [_moviePlayer prepareToPlay];
    
    // Play
    [_moviePlayer play];
    
    // Set Playback State
    _movieIsPlaying = YES;
    
    // Finish
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name: MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
}

- (void)playbackFinished {
    _movieIsPlaying = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(NSString *) getMoviePath:(NSInteger)index {
    NSString *mMovieName = @"";
    switch (index) {
        case 0: // AMY
            mMovieName = @"leaving";
            break;
        case 1: // CLAIRE
            mMovieName = @"exhibita";
            break;
        case 2: // JESS
            mMovieName = @"portability";
            break;
        case 3: // KIKI
            mMovieName = @"stall";
            break;
        case 4: // MARCI
            mMovieName = @"plant";
            break;
        case 5: // MILY
            mMovieName = @"cirque";
            break;
        case 6: // SULTAN1
            mMovieName = @"letter pt1";
            break;
        case 7: // SULTAN2
            mMovieName = @"letter pt2";
            break;
        default:
            mMovieName = @"";
    }
    return mMovieName;
}


@end
