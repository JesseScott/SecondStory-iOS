//
//  FeedbackViewController.h
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController : UIViewController <MFMailComposeViewControllerDelegate, UITextFieldDelegate> {
    
}

- (IBAction)sendfeedback:(id)sender;

@end
