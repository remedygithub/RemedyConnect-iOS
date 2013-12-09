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
#import <CoreLocation/CoreLocation.h>

@interface PracticeSearchViewController ()

@end

@implementation PracticeSearchViewController
Logic *logic;
UIGestureRecognizer *tapper;
UITextField *activeField;
CLLocationManager *locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

// Implementation for scrolling along with the keyboard is taken from
// http://stackoverflow.com/a/4837510/238845

- (IBAction)startDownloading:(id)sender {
    logic = [Logic sharedLogic];
    [logic setPracticeListDownloadStarterDelegate:self];
    [logic startDownloadingRootForPracticeSelectionByName:_practiceNameField.text];
}

- (IBAction)startLocationSearch:(id)sender {
    if (nil == locationManager) {
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
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
}

- (void)hasFailed {
    [statusHUD setLabelText:@"Failed to download files.\nPlease try again later."];
    [statusHUD hide:YES afterDelay:2];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [statusHUD setLabelText:@"Found location."];
    [statusHUD hide:YES afterDelay:2];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [statusHUD setLabelText:@"Couldn't find location. Please search by name."];
    [statusHUD hide:YES afterDelay:2];
}

@end
