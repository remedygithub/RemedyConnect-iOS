//
//  SelectPracticeTableViewController.h
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.18..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Downloader.h"

@interface SelectPracticeTableViewController : UITableViewController <MBProgressHUDDelegate, DownloaderDelegate>
{
    MBProgressHUD *statusHUD;
}

@property (nonatomic, strong) NSArray *practiceNames;
@property (nonatomic, strong) NSArray *practiceFeeds;
@property (nonatomic, strong) NSArray *practiceLocations;

#pragma mark DownloaderDelegate
- (void)hasStartedDownloadingFirst;
- (void)hasStartedDownloadingNext;
- (void)didReceiveResponseForAFile;
- (void)didReceiveDataForAFile;
- (void)didFinishForAFile;
- (void)hasFailedToDownloadAFile;

@end
