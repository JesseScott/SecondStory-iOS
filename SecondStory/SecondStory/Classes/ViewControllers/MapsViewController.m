//
//  MapsViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "MapsViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "YTPlayerView.h"


#pragma mark - CONSTANTS -



#pragma mark - INTERFACE -

@interface MapsViewController ()

@property (weak, nonatomic) NSArray *youtubeIDS;
@property (weak, nonatomic) NSArray *fileNames;
@property (weak, nonatomic) NSString *matchedFile;

@property BOOL movieIsPlaying;
@property BOOL shouldPlayLocal;

@property (weak, nonatomic) NSString *LOCAL_MEDIA_PATH;
@property (weak, nonatomic) NSString *LOCAL_FILE;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *videoView;

@property (nonatomic, strong) IBOutlet YTPlayerView *youtubeView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tap;

@property (weak, nonatomic) IBOutlet UIButton *beefButton;
@property (weak, nonatomic) IBOutlet UIButton *penniesButton;
@property (weak, nonatomic) IBOutlet UIButton *sweepingButton;
@property (weak, nonatomic) IBOutlet UIButton *copperButton;
@property (weak, nonatomic) IBOutlet UIButton *macrameButton;
@property (weak, nonatomic) IBOutlet UIButton *umbrellasButton;
@property (weak, nonatomic) IBOutlet UIButton *alleyButton;
@property (weak, nonatomic) IBOutlet UIButton *bikeButton;
@property (weak, nonatomic) IBOutlet UIButton *gunButton;

@end


#pragma mark - IMPLEMENTATION -


@implementation MapsViewController


#pragma mark - LIFECYCLE -

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // PATHS
    NSString *customPath = @"/SecondStory/BloodAlley/MEDIA";
    _LOCAL_MEDIA_PATH = [[self returnDocumentsDirectory] stringByAppendingPathComponent:customPath];

    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //LOCAL_MEDIA_PATH = [documentsDirectory stringByAppendingPathComponent:customPath];
    
    [self listCustomDirectory];
    
    _shouldPlayLocal = YES;
    if([self returnSizeOfDirectory] == 0) {
        _shouldPlayLocal = NO;
    }
    
    // Arrays
//    youtubeIDS = [NSArray arrayWithObjects:
//                  @"N0L1xyy8tqA", // BEEF
//                  @"5npVxU_FMxg", // BIKE
//                  @"-zHUf_d3tUM", // ALLEY
//                  @"ZaM6fWMAu-Q", // COPPER
//                  @"VqKuwHpkI4o", // GUN
//                  @"UA_T7eHy8mM", // PENNIES
//                  @"YDkUmpZYcXc", // SHROOMS
//                  @"F4BiLpAxFTs", // SWEEPING
//                  @"vwLm44Og9xU", // UMBRELLAS
//                  nil];
    
    _fileNames = [NSArray arrayWithObjects:
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
    _moviePlayer = [[MPMoviePlayerController alloc] init];
                   
    // Hide Video View
    [self.view addSubview:self.videoView];
    [self.videoView setHidden:YES];
    [self.view addSubview:_youtubeView];
    [self.youtubeView setHidden:YES];
    
    
    // Set Playback State
    _movieIsPlaying = NO;
    
    // Tap
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    // Lifecycle
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(pauseVideo)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(resumeVideo)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
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
    
    _youtubeIDS = [NSArray arrayWithObjects:
                  @"N0L1xyy8tqA", // BEEF
                  @"5npVxU_FMxg", // BIKE
                  @"-zHUf_d3tUM", // ALLEY
                  @"ZaM6fWMAu-Q", // COPPER
                  @"VqKuwHpkI4o", // GUN
                  @"UA_T7eHy8mM", // PENNIES
                  @"YDkUmpZYcXc", // SHROOMS
                  @"F4BiLpAxFTs", // SWEEPING
                  @"vwLm44Og9xU", // UMBRELLAS
                  nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    if(!_movieIsPlaying) {
        [_moviePlayer stop];
        _moviePlayer = nil;
        _youtubeIDS = nil;
    }
    [self.videoView setHidden:YES];
}


# pragma mark - VIDEO -

- (void)loadVideo: (NSURL*) videoUrl {
    
    // Show View
    [self.videoView setHidden:NO];
    
    // Hide Youtube
    [self.youtubeView setHidden:YES];

    //Set URL
    [_moviePlayer setContentURL:videoUrl];
    
    //Set Frame
    _moviePlayer.view.frame = CGRectMake(40, 203, 240, 128);
    [self.view addSubview:[_moviePlayer view]];
    
    // Controls
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    
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
    // Hide Video View
    [self.videoView setHidden:YES];
    // Set Playback State
    _movieIsPlaying = NO;
}

- (void)loadStream: (int) index {
    if (_youtubeIDS != nil) {
        // Hide Video View
        [self.videoView setHidden:YES];
        
        // Show Youtube View
        [self.youtubeView setHidden:NO];
        
        if ([self.youtubeView loadWithVideoId:[_youtubeIDS objectAtIndex:index]]) {
            NSLog(@"Loaded Youtube");
            if(self.youtubeView.playerState != kYTPlayerStatePlaying){
                [self.youtubeView playVideo];
            }
        }
        else {
            NSLog(@"Error Youtube");
        }
    }
}

- (void) pauseVideo {
    NSLog(@"PAUSE");
    if([_moviePlayer playbackState] == MPMoviePlaybackStatePlaying ) {
        [_moviePlayer pause];
    }
}

- (void) resumeVideo {
    NSLog(@"RESUME");
    if([_moviePlayer playbackState] == MPMoviePlaybackStatePaused ) {
        [_moviePlayer play];
    }
}


# pragma mark - FILES -


- (BOOL) videoIsLocal: (int) index {
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_LOCAL_MEDIA_PATH error:nil];
    NSString *fileNameToMatch = [_fileNames objectAtIndex:index];
    BOOL match = NO;
    for (int i = 0; i < [contents count]; i++) {
        NSLog(@"Item #%i is %@", i, [contents objectAtIndex:i]);
        if ([[contents objectAtIndex:i] isEqualToString:fileNameToMatch]) {
            NSLog(@"MATCH");
            _LOCAL_FILE = fileNameToMatch;
            return YES;
        }
    }
    return match;
}

- (NSString*) returnDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doc = [paths objectAtIndex:0];
    return doc;
}

- (NSURL*) prepLocalURL {
    NSString *file = [_LOCAL_MEDIA_PATH stringByAppendingString:@"/"];
    file = [file stringByAppendingString:_LOCAL_FILE];
    return [NSURL fileURLWithPath:file];
}

- (void) listCustomDirectory {
    NSError *error = nil;
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_LOCAL_MEDIA_PATH error:&error];
    NSLog(@"DIRECTORY HAS %lu FILES", (unsigned long)[contents count]);
    for (int i = 0; i < [contents count]; i++) {
        NSLog(@"Item #%i is %@", i, [contents objectAtIndex:i]);
    }
}

- (int) returnSizeOfDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:_LOCAL_MEDIA_PATH];
    NSError *error = nil;
    NSArray  *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:&error];
    return (int)[contents count];
}


# pragma mark - ACTIONS -


- (IBAction) clickedPin:(id)sender {
    if(!_movieIsPlaying) {
        if([self videoIsLocal:(int)[sender tag]]) {
            [self loadVideo:[self prepLocalURL]];
        }
        else {
            NSLog(@"NOT LOCAL");
            [self loadStream:(int)[sender tag]];
        }
    }
    else {
        [_moviePlayer stop];
        self.videoView.hidden = YES;
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [_moviePlayer stop];
    [self.videoView setHidden:YES];
}

- (IBAction)tapped:(id)sender {
    //NSLog(@"TAPPED IBA");
}

- (IBAction)clickedCamera:(id)sender {
    //
}


@end
