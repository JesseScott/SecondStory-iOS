//
//  MapsViewController.h
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@interface MapsViewController : UIViewController {
    NSString *videoURL;
    MPMoviePlayerController *moviePlayer;
    
    BOOL movieIsPlaying;
    BOOL shouldPlayLocal;
    
    NSString *LOCAL_MEDIA_PATH;
    NSString *LOCAL_FILE;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *videoView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;

@property (weak, nonatomic) IBOutlet UIButton *beefButton;
@property (weak, nonatomic) IBOutlet UIButton *penniesButton;
@property (weak, nonatomic) IBOutlet UIButton *sweepingButton;
@property (weak, nonatomic) IBOutlet UIButton *copperButton;
@property (weak, nonatomic) IBOutlet UIButton *macrameButton;
@property (weak, nonatomic) IBOutlet UIButton *umbrellasButton;
@property (weak, nonatomic) IBOutlet UIButton *alleyButton;
@property (weak, nonatomic) IBOutlet UIButton *bikeButton;
@property (weak, nonatomic) IBOutlet UIButton *gunButton;

- (IBAction)clickedBeef:(id)sender;
- (IBAction)clickedPennies:(id)sender;
- (IBAction)clickedSweeping:(id)sender;
- (IBAction)clickedCopper:(id)sender;
- (IBAction)clickedMacrame:(id)sender;
- (IBAction)clickedUmbrellas:(id)sender;
- (IBAction)clickedAlley:(id)sender;
- (IBAction)clickedBike:(id)sender;
- (IBAction)clickedGun:(id)sender;
- (IBAction)tapped:(id)sender;



@end
