//
//  MainMenuViewController.h
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Downloader.h"

@interface MainMenuViewController : UIViewController <MBProgressHUDDelegate, DownloaderDelegate>
{
    MBProgressHUD *statusHUD;
}

#pragma mark DownloaderDelegate
- (void)hasStartedDownloadingFirst;
- (void)hasStartedDownloadingNext;
- (void)didReceiveResponseForAFile;
- (void)didReceiveDataForAFile;
- (void)didFinishForAFile;
- (void)hasFailedToDownloadAFile;
@end
