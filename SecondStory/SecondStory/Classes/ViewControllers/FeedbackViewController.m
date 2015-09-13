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

@property (weak, nonatomic) UIFont *mFont;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextView *messageField;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;


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
    
    NSLog(@" --- FEEDBACK ---- ");
    
    // Font
    self.mFont = [UIFont fontWithName:@"Din Alternate Medium" size:24];
    
    
    // Buttons
    
    [_feedbackBtn.titleLabel setFont:_mFont];
    _feedbackBtn.layer.borderWidth = 3.0f;
    _feedbackBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    // Delegates
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    self.messageField.delegate = self;
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Colours
    UIColor *duRed = [UIColor colorWithRed:(239/255.0f) green:(64/255.0f) blue:(54/255.0f) alpha:(255/255.0f)];

    // Font
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, self.mFont, NSFontAttributeName, nil];

    // Nav Bar
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:duRed];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
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
