//
//  SelectPracticeTableViewController.h
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.18..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Logic.h"

@interface SelectPracticeTableViewController : UITableViewController <MBProgressHUDDelegate, MainDownloadStarterDelegate>
{
    MBProgressHUD *statusHUD;
}

@property (nonatomic, strong) NSString *searchString;

#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading;
- (void)switchToIndeterminate;
- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status;
- (void)updateProgress:(DownloadStatus *)status;
- (void)didFinish;
- (void)hasFailed;

@end
