//
//  PracticeSearchViewController.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.04..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "PracticeSearchViewController.h"
#import "SelectPracticeTableViewController.h"
#import "SearchURLGenerator.h"
#import "FileHandling.h"
#import "Data.h"
#import "Parser.h"
#import "ReachabilityManager.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface PracticeSearchViewController ()
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation PracticeSearchViewController
Logic *logic;
UIGestureRecognizer *tapper;
UITextField *activeField;
CLLocationManager *locationManager;
NSLayoutConstraint *oldConstraint;

// Implementation for scrolling along with the keyboard is taken from
// http://stackoverflow.com/a/4837510/238845

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self registerForKeyboardNotifications];
    
    [self.view endEditing:YES];
    
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE
                                            withAnimation:UIStatusBarAnimationFade];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)showNoConnectionPopup {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection"
                                                    message:@"Couldn't reach server. Please check your internet connection and try again."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self startDownloading:nil];
    return YES;
}

- (IBAction)startDownloading:(id)sender {
    if ([ReachabilityManager isReachable])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_practiceNameField.text forKey:@"nameOfPratice"];
        [defaults synchronize];
        logic = [Logic sharedLogic];
        [logic setPracticeListDownloadStarterDelegate:self];
        [logic startDownloadingRootForPracticeSelectionByName:_practiceNameField.text];
    }
    else {
        [self showNoConnectionPopup];
    }
    
}

- (IBAction)startLocationSearch:(id)sender {
    if ([ReachabilityManager isReachable])
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.distanceFilter = 500;
        if(IS_OS_8_OR_LATER)
        {
            //Use one or the other, not both. Depending on what you put in info.plist
            [locationManager requestWhenInUseAuthorization];
            [locationManager requestAlwaysAuthorization];
        }
        [locationManager startUpdatingLocation];
        statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
        [statusHUD setDelegate:self];
        [statusHUD setDimBackground:TRUE];
        [statusHUD setLabelText:@"Waiting for location..."];
    }
    else {
        [self showNoConnectionPopup];
    }
}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
//                                                                      attribute:NSLayoutAttributeLeading
//                                                                      relatedBy:0
//                                                                         toItem:self.view
//                                                                      attribute:NSLayoutAttributeLeft
//                                                                     multiplier:1.0
//                                                                       constant:0];
//    [self.view addConstraint:leftConstraint];
//    
//    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
//                                                                       attribute:NSLayoutAttributeTrailing
//                                                                       relatedBy:0
//                                                                          toItem:self.view
//                                                                       attribute:NSLayoutAttributeRight
//                                                                      multiplier:1.0
//                                                                        constant:0];
//    [self.view addConstraint:rightConstraint];
//    
//   // BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
//    BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation );
//
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenHeight;
//    if (!isLandscape) {
//        screenHeight = screenRect.size.height;
//    }
//    else {
//        screenHeight = screenRect.size.width;
//    }
//    
//    //CGRect screenRect = [[UIScreen mainScreen] bounds];
//    //CGFloat screenHeight = screenRect.size.height;
//    
//    _containerHeightConstraint.constant = screenHeight;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    UILabel *magnifyingGlass = [[UILabel alloc] init];
    [magnifyingGlass setText:[[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"]];
    [magnifyingGlass sizeToFit];
    
    _searchButton.titleLabel.numberOfLines = 1;
    _searchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _searchButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    _searchButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    [_practiceNameField setLeftView:magnifyingGlass];
    [_practiceNameField setLeftViewMode:UITextFieldViewModeAlways];
    [_practiceNameField setDelegate:self];
    
    _locationView.layer.cornerRadius = 4;
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    _scrollView.contentSize = CGSizeMake(1, screenHeight);
    
}
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
//     {
//         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//         // do whatever
//         if (orientation == UIInterfaceOrientationPortrait ||orientation == UIInterfaceOrientationPortraitUpsideDown ) {
//             // constant to zero
//             _bottomConstraint.constant = 0;
//         }
//         else{
//             //constant to 10
//             _bottomConstraint.constant = 15;
//         }
//         
//     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
//     {
//         
//     }];
//    
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//}
- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[statusHUD removeFromSuperview];
	statusHUD = nil;
}

#pragma mark - DownloaderUIDelegate

- (void)hasStartedDownloading {
    if (nil != statusHUD) {
        [statusHUD hide:TRUE];
    }
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD setLabelText:@"Starting download..."];
}

- (void)switchToIndeterminate {
    [statusHUD setMode:MBProgressHUDModeIndeterminate];
}

- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status {
    [statusHUD setMode:MBProgressHUDModeDeterminate];
    [statusHUD setLabelText:
     [[NSString alloc] initWithFormat:@"Downloading %d/%d...",
      [status currentFileIndex] + 1,
      [status numberOfFilesToDownload]]];
    
}

- (void)updateProgress:(DownloadStatus *)status {
    if ([status expectedLength] > 0) {
        statusHUD.progress = [status currentLength] / (float)[status expectedLength];
    }
}

- (void)didFinish {
    [statusHUD setMode:MBProgressHUDModeText];
    [statusHUD setLabelText:@"Finished!"];
    [statusHUD hide:YES afterDelay:2];
    if ([[logic getPracticeList] count] == 0) {
        [logic setCanAdvanceToPracticeSelect:FALSE];
        NSString *message;
        if ([logic locationBasedSearch]) {
            message = @"It seems there are no practices near you. Please try searching by name.";
        }
        else {
            message = @"Please check your spelling and try again.";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't find any practices"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [statusHUD hide:YES];
        [alert show];
    }
    else {
        [logic setCanAdvanceToPracticeSelect:TRUE];
    }
}

- (void)hasFailed {
    [statusHUD setMode:MBProgressHUDModeText];
    [statusHUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to download files"
                                                    message:@"Please check your internet connection and try again."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [statusHUD setLabelText:@"Found location."];
    [statusHUD hide:YES afterDelay:2];
    CLLocation *location = [locations lastObject];
    logic = [Logic sharedLogic];
    [logic setPracticeListDownloadStarterDelegate:self];
    [logic startDownloadingRootForPracticeSelectionByLocation:location];
    [manager stopUpdatingHeading];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [statusHUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't find location"
                                                    message:@"Please try searching by name instead."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        //[self.scrollView scrollRectToVisible:activeField.frame animated:YES];
        self.bottomConstraint.constant = -kbSize.height+25;

        [UIView animateWithDuration:0.3f
                         animations:^{
                              [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished){
                             
                         }
         
    ];
}
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    self.bottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         
                     }
     
     ];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}
@end
