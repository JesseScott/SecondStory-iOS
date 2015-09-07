//
//  GalleryViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2015-07-29.
//  Copyright (c) 2015 The Only Animal. All rights reserved.
//

#import "GalleryViewController.h"
#import "FullScreenVideoControllerViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>


#pragma mark - CONSTANTS -

#pragma mark - INTERFACE -

@interface GalleryViewController ()  <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwiperecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property BOOL movieIsPlaying;

@end

#pragma mark - IMPLEMENTATION -

@implementation GalleryViewController

#pragma mark - LIFECYCLE -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Alloc Player
    _moviePlayer = [[MPMoviePlayerController alloc] init];

    currentIndex = 0;
    
    _leftSwiperecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    _leftSwiperecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftSwiperecognizer.delegate = self;
    [self.view addGestureRecognizer:_leftSwiperecognizer];
    
    _rightSwipRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    _rightSwipRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    _rightSwipRecognizer.delegate = self;
    [self.view addGestureRecognizer:_rightSwipRecognizer];
    
    imageArray = [NSArray arrayWithObjects:
                   [UIImage imageNamed:@"amy.jpg"],
                   [UIImage imageNamed:@"claire.jpg"],
                   [UIImage imageNamed:@"jess.jpg"],
                   [UIImage imageNamed:@"kiki.jpg"],
                   [UIImage imageNamed:@"marci.jpg"],
                   [UIImage imageNamed:@"mily.jpg"],
                   [UIImage imageNamed:@"sultan.jpg"],
                   nil];
    
    [_imageView setImage:[imageArray objectAtIndex:currentIndex]];

    titleArray = [NSArray arrayWithObjects:
                  @"Cirque Dystopic",
                  @"Exhibit A",
                  @"Leaving the House",
                  @"A Letter Too Late Pt1",
                  @"A Letter Too Late Pt2",
                  @"Plant",
                  @"Portability",
                  @"Stall 43",
                  nil];
    
    self.titleLabel.text = [titleArray objectAtIndex:currentIndex];
    
    artistArray = [NSArray arrayWithObjects:
                  @"Mily Mumford",
                  @"Claire Love Wilson",
                  @"Amy Dauer",
                  @"Sultan Owaisi",
                  @"Sultan Owaisi",
                  @"Marcela Amaya",
                  @"Jess Amy Shead",
                  @"Baraka Ramini",
                  nil];
    
    self.artistLabel.text = [artistArray objectAtIndex:currentIndex];

    
}

#pragma mark - ACTIONS -

-(void)swipeLeft:(UISwipeGestureRecognizer *)recognizer {
    if (currentIndex < [imageArray count] -1) {
        currentIndex++;
        [_imageView setImage:[imageArray objectAtIndex:currentIndex]];
        self.titleLabel.text = [titleArray objectAtIndex:currentIndex];
        self.artistLabel.text = [artistArray objectAtIndex:currentIndex];
    }
}

-(void)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    if(currentIndex > 0) {
        currentIndex--;
        [_imageView setImage:[imageArray objectAtIndex:currentIndex]];
        self.titleLabel.text = [titleArray objectAtIndex:currentIndex];
        self.artistLabel.text = [artistArray objectAtIndex:currentIndex];
    }
}

# pragma mark - VIDEO -

- (void)loadVideo: (NSURL *) videoUrl {
    
    
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
    _movieIsPlaying = NO;
}

- (IBAction)fireVideo:(id)sender {
    FullScreenVideoControllerViewController *vc = [[FullScreenVideoControllerViewController alloc] initWithNibName:@"FullScreenVideoControllerViewController" bundle:nil];
    //[self.navigationController pushViewController:vc animated:YES];
    [vc initMoviePlayerWithIndex:&(currentIndex)];
    [self.navigationController presentViewController:vc animated:YES completion:nil];

    
    /*
    NSString *movie = [self getMoviePath:currentIndex];
    NSString *path = [[NSBundle mainBundle]pathForResource:movie ofType:@"mp4"];
    NSLog(@"Full Path for Asset: %@", path);
    [self loadVideo:[NSURL fileURLWithPath:path]];
     */
}

-(NSString *) getMoviePath:(int)index {
    NSString *mMovieName = @"";
    switch (index) {
            //            case 0: // Beef
            //                mMovieName = MEDIA_PATH + "beef.mp4";
            //                break;
        case 1: // Pennies
            mMovieName = @"exhibita";
            break;
        case 2: // Sweeping
            mMovieName = @"leaving";
            break;
        case 3: // Copper
            mMovieName = @"letter pt1";
            break;
        case 4: // Shrooms
            mMovieName = @"letter pt2";
            break;
        case 5: // Umbrellas
            mMovieName = @"plant";
            break;
        case 6: // Alley
            mMovieName = @"portability";
            break;
        case 7: // Bicycles
            mMovieName = @"stall";
            break;

        default:
            mMovieName = @"";
    }
    return mMovieName;
;
}





@end
