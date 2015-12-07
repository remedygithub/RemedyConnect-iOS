//
//  PracticeSearchViewController.h
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.04..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Logic.h"
#import "Downloader.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <CoreLocation/CoreLocation.h>

@interface PracticeSearchViewController : UIViewController <MBProgressHUDDelegate, PracticeListDownloadStarterDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UIScrollViewDelegate>
{
    MBProgressHUD *statusHUD;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *practiceNameField;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
- (IBAction)startDownloading:(id)sender;
- (IBAction)startLocationSearch:(id)sender;

#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading;
- (void)switchToIndeterminate;
- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status;
- (void)updateProgress:(DownloadStatus *)status;
- (void)didFinish;
- (void)hasFailed;

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end

