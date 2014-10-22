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
@synthesize youtubeView;
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
    
    [self listCustomDirectory];
    
    shouldPlayLocal = YES;
    if([self returnSizeOfDirectory] == 0) {
        shouldPlayLocal = NO;
    }
    
    // Arrays
    youtubeIDS = [NSArray arrayWithObjects:
                    @"N0L1xyy8tqA", // BEEF
                    @"5npVxU_FMxg", // BIKE
                    @"-zHUf_d3tUM", // ALLEY
                    @"ZaM6fWMAu-Q",   // COPPER
                    @"VqKuwHpkI4o", // GUN
                    @"UA_T7eHy8mM", // PENNIES
                    @"YDkUmpZYcXc", // SHROOMS
                    @"F4BiLpAxFTs", // SWEEPING
                    @"vwLm44Og9xU", // UMBRELLAS
                  nil];
    
    fileNames = [NSArray arrayWithObjects:
                    @"beef.mp4",
                    @"bicycles.mp4",
                    @"bloodalley.mp4",
                    @"copperthief.mp4",
                    @"gun.mp4",
                    @"pennies.mp4",
                    @"shrooms.mp4",
                    @"sweeping.mp4",
                    @"umbrellas.mp4",
                 nil];

    // Alloc Player
    moviePlayer = [[MPMoviePlayerController alloc] init];
                   
    // Hide Video View
    [self.view addSubview:self.videoView];
    [self.videoView setHidden:YES];
    [self.view addSubview:youtubeView];
    [self.youtubeView setHidden:YES];
    
    
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

- (void)loadVideo: (NSURL*) videoUrl {
    
    // Show View
    [self.videoView setHidden:NO];
    
    // Hide Youtube
    [self.youtubeView setHidden:YES];

    //Set URL
    [moviePlayer setContentURL:videoUrl];
    
    //Set Frame
    moviePlayer.view.frame = CGRectMake(40, 203, 240, 128);
    [self.view addSubview:[moviePlayer view]];
    
    // Controls
    moviePlayer.controlStyle = MPMovieControlStyleDefault;
    
    // Loop Video
    moviePlayer.repeatMode = MPMovieRepeatModeNone;
    
    // Prepare
    [moviePlayer prepareToPlay];
    
    // Play
    [moviePlayer play];
    
    // Finish
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name: MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
}

- (void)playbackFinished {
    // Hide Video View
    [self.videoView setHidden:YES];
}

- (void)loadStream: (int) index {
    // Hide Video View
    [self.videoView setHidden:YES];
    
    // Show Youtube View
    [self.youtubeView setHidden:NO];
    [self.youtubeView loadWithVideoId:[youtubeIDS objectAtIndex:index]];
}

# pragma mark FILE

- (BOOL) videoIsLocal: (int) index {
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:LOCAL_MEDIA_PATH error:nil];
    NSString *fileNameToMatch = [fileNames objectAtIndex:index];
    BOOL match = NO;
    for (int i = 0; i < [contents count]; i++) {
        NSLog(@"Item #%i is %@", i, [contents objectAtIndex:i]);
        if ([[contents objectAtIndex:i] isEqualToString:fileNameToMatch]) {
            NSLog(@"MATCH");
            LOCAL_FILE = fileNameToMatch;
            return YES;
        }
    }
    return match;
}


- (NSURL*) prepLocalURL {
    NSString *file = [LOCAL_MEDIA_PATH stringByAppendingString:@"/"];
    file = [file stringByAppendingString:LOCAL_FILE];
    NSURL *url = [NSURL fileURLWithPath:file];
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


- (IBAction) clickedPin:(id)sender {
    if(!movieIsPlaying) {
        if([self videoIsLocal:[sender tag]]) {
            [self loadVideo:[self prepLocalURL]];
        }
        else {
            NSLog(@"NOT LOCAL");
            [self loadStream:[sender tag]];
        }
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
