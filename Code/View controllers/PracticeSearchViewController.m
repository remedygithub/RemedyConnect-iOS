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

@interface PracticeSearchViewController ()

@end

@implementation PracticeSearchViewController
Logic *logic;
UIGestureRecognizer *tapper;
UITextField *activeField;
CLLocationManager *locationManager;

// Implementation for scrolling along with the keyboard is taken from
// http://stackoverflow.com/a/4837510/238845

- (void)showNoConnectionPopup {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection"
                                                    message:@"Couldn't reach server. Please check your internet connection and try again."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)startDownloading:(id)sender {
    if ([ReachabilityManager isReachable]) {
        logic = [Logic sharedLogic];
        [logic setPracticeListDownloadStarterDelegate:self];
        [logic startDownloadingRootForPracticeSelectionByName:_practiceNameField.text];
    }
    else {
        [self showNoConnectionPopup];
    }
    
}

- (IBAction)startLocationSearch:(id)sender {
    if ([ReachabilityManager isReachable]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.distanceFilter = 500;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
}

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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [statusHUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't find location"
                                                    message:@"Please try searching by name instead."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
