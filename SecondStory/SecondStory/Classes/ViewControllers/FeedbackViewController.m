//
//  FeedbackViewController.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-09-14.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "FeedbackViewController.h"
#import <Parse/Parse.h>



#pragma mark - INTERFACE -

@interface FeedbackViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextView *messageField;


@end


#pragma mark - IMPLEMENTATION -


@implementation FeedbackViewController


#pragma mark - LIFECYCLE -

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Delegates
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    self.messageField.delegate = self;
    
}

- (void) viewWillAppear:(BOOL)animated {
    // Colours
    //UIColor *bgColor = [UIColor colorWithRed:(39/255.0f) green:(49/255.0f) blue:(59/255.0f) alpha:(165/255.0f)];
    UIColor *fontColor = [UIColor colorWithRed:(213/255.0f) green:(220/255.0f) blue:(225/255.0f) alpha:(255/255.0f)];
    
    // Font
    UIFont *navFont = [UIFont fontWithName:@"Din Alternate Black" size:24];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: fontColor, NSForegroundColorAttributeName, navFont, NSFontAttributeName, nil];
    
    // Nav Bar
    self.navigationController.navigationBar.tintColor = fontColor;
    //[self.navigationController.navigationBar setBackgroundColor:bgColor];
    [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
}


#pragma mark - ACTIONS -


- (IBAction)sendfeedback:(id)sender {
    
    PFObject *feedback = [PFObject objectWithClassName:@"FEEDBACK"];
    feedback[@"name"] = self.nameField.text;
    feedback[@"email"] = self.emailField.text;
    feedback[@"message"] = self.messageField.text;
    [feedback saveEventually];
    
    NSLog(@"Feedback Submitted");
    
    self.nameField.text = @"";
    self.emailField.text = @"";
    self.messageField.text = @"";
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You"
                                                    message:@"Your feedback has been submitted"
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
}

#pragma mark - DELEGATES -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}



@end
