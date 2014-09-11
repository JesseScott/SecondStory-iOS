


#import "VideoPlaybackViewController.h"
/*
#import <QCAR/QCAR.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ImageTracker.h>
#import <QCAR/DataSet.h>
#import <QCAR/Trackable.h>
#import <QCAR/CameraDevice.h>
*/

@implementation VideoPlaybackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}


- (void)loadView
{
 
}

- (void) pauseAR {

}

- (void) resumeAR {
  
}



- (void)viewDidLoad
{
    [super viewDidLoad];
   }
    
- (void)viewWillDisappear:(BOOL)animated {


}

- (void)finishOpenGLESCommands
{

}


- (void)freeOpenGLESResources
{

}


//------------------------------------------------------------------------------
#pragma mark - Autorotation

- (NSUInteger)supportedInterfaceOrientations
{
    // iOS >= 6
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return [self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// double tap handler
- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"show_menu" object:self];
}

// tap handler
- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        // handling code
        //CGPoint touchPoint = [sender locationInView:eaglView];
        //[eaglView handleTouchPoint:touchPoint];
    }
}

- (void) dimissController:(id) sender {
    self.navigationController.navigationBar.translucent = NO;

    [self.navigationController popViewControllerAnimated:YES];
}


// Present a view controller using the root view controller (eaglViewController)
- (void)rootViewControllerPresentViewController:(UIViewController*)viewController inContext:(BOOL)currentContext
{

}

// Dismiss a view controller presented by the root view controller
// (eaglViewController)
- (void)rootViewControllerDismissPresentedViewController
{


}

@end