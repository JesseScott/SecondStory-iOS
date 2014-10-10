//
//  GuideViewController.h
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface GuideViewController : UIViewController {
    AVAudioPlayer *player;
    BOOL playerIsPlaying;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *replayBtn;
- (IBAction)replayAudio:(id)sender;


@end
