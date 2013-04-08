//
//  GPViewController.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.02..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Downloader.h"

@interface GPViewController : UIViewController <MBProgressHUDDelegate, DownloaderDelegate>
{
    MBProgressHUD *statusHUD;
}
- (IBAction)startDownload:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startDownloadButton;

// DownloaderDelegate
- (void)hasStartedDownloadingFirst;
- (void)hasStartedDownloadingNext;
- (void)didReceiveResponseForAFile;
- (void)didReceiveDataForAFile;
- (void)didFinishForAFile;
- (void)hasFailedToDownloadAFile;
@end
