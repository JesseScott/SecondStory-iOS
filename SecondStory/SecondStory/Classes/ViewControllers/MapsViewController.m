//
//  MapsViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "MapsViewController.h"


@implementation MapsViewController

# pragma mark SYNTHESIZE

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

# pragma mark VIEW

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // PATHS
    NSString *customPath = @"/SecondStory/BloodAlley/MEDIA";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    LOCAL_MEDIA_PATH = [documentsDirectory stringByAppendingPathComponent:customPath];
    
    shouldPlayLocal = YES;
    if([self returnSizeOfDirectory] == 0) {
        shouldPlayLocal = NO;
    }

    // Hide Video View
    [self.view addSubview:self.videoView];
    [self.videoView setHidden:YES];
    
    // Set Playback State
    movieIsPlaying = NO;
    
    // Tap
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void) viewWillAppear:(BOOL)animated {
    // Colours
    UIColor *bgColor = [UIColor colorWithRed:(51/255.0f) green:(51/255.0f) blue:(51/255.0f) alpha:(164/255.0f)];
    UIColor *fontColor = [UIColor colorWithRed:(206/255.0f) green:(235/255.0f) blue:(255/255.0f) alpha:(255/255.0f)];
    
    // Font
    UIFont *navFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: fontColor, NSForegroundColorAttributeName, navFont, NSFontAttributeName, nil];
    
    // Nav Bar
    self.navigationController.navigationBar.tintColor = fontColor;
    [self.navigationController.navigationBar setBackgroundColor:bgColor];
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [moviePlayer stop];
    [self.videoView setHidden:YES];
}


# pragma mark VIDEO

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

# pragma mark FILE

- (BOOL) videoIsLocal: (int) index {

    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:LOCAL_MEDIA_PATH error:nil];
    if([contents count] < index) {
        return NO;
    }
    else  {
        return YES;
    }
}

- (NSURL*) returnPathofFileForIndex :(int) index {
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:LOCAL_MEDIA_PATH error:nil];
    NSString *file = [LOCAL_MEDIA_PATH stringByAppendingString:@"/"];
    file = [file stringByAppendingString:[contents objectAtIndex:index]];
    
    NSURL *url = [NSURL URLWithString:file];
    return url;
}

- (void) listCustomDirectory {
    
    NSError *error = nil;
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:LOCAL_MEDIA_PATH error:&error];
    NSLog(@"DIRECTORY HAS %i FILES", [contents count]);
    for (int i = 0; i < [contents count]; i++) {
        NSLog(@"Item #%i is %@", i, [contents objectAtIndex:i]);
    }
}

- (int) returnSizeOfDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:LOCAL_MEDIA_PATH];
    NSError *error = nil;
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:&error];
    
    return [contents count];
}


# pragma mark IBACTION


- (IBAction)clickedBeef:(id)sender {
    if(!movieIsPlaying) {
        NSURL *url;
        if(![self videoIsLocal:0] && shouldPlayLocal == YES) {
            url = [[NSBundle mainBundle] URLForResource:@"beef" withExtension:@"mp4"];
        }
        else {
            url = [self returnPathofFileForIndex:0];
        }
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
