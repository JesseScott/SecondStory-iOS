//
//  FeedbackViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "FeedbackViewController.h"
#import <MessageUI/MessageUI.h>


#pragma mark - CONSTANTS -

#define EMAIL_SUBJECT   @"Feedback - 2nd Story"
#define EMAIL_RECIPIENT @"info@theonlyanimal.com"

#pragma mark - INTERFACE -

@interface FeedbackViewController () <MFMailComposeViewControllerDelegate, UITextFieldDelegate> 

@end


#pragma mark - IMPLEMENTATION -


@implementation FeedbackViewController


#pragma mark - LIFECYCLE -


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    // Colours
    UIColor *bgColor = [UIColor colorWithRed:(39/255.0f) green:(49/255.0f) blue:(59/255.0f) alpha:(165/255.0f)];
    UIColor *fontColor = [UIColor colorWithRed:(213/255.0f) green:(220/255.0f) blue:(225/255.0f) alpha:(255/255.0f)];
    
    // Font
    UIFont *navFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: fontColor, NSForegroundColorAttributeName, navFont, NSFontAttributeName, nil];
    
    // Nav Bar
    self.navigationController.navigationBar.tintColor = fontColor;
    [self.navigationController.navigationBar setBackgroundColor:bgColor];
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
}


#pragma mark - ACTIONS -


- (IBAction)sendfeedback:(id)sender {
    [self startEmail];
}

#pragma mark - EMAIL -


- (void) startEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:EMAIL_SUBJECT];
        NSArray *toRecipients = [NSArray arrayWithObjects:EMAIL_RECIPIENT, nil];
        [mailer setToRecipients:toRecipients];
        
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Your device doesn't have a mail account setup"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            //NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
