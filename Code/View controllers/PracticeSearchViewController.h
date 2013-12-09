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


@interface PracticeSearchViewController : UIViewController <MBProgressHUDDelegate, PracticeListDownloadStarterDelegate>
{
    MBProgressHUD *statusHUD;
}

@property (weak, nonatomic) IBOutlet UITextField *practiceNameField;
- (IBAction)startDownloading:(id)sender;

#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading;
- (void)switchToIndeterminate;
- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status;
- (void)updateProgress:(DownloadStatus *)status;
- (void)didFinish;
- (void)hasFailed;
@end

