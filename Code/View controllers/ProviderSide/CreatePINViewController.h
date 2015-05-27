//
//  CreatePINViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 08/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macros.h"
#import "PAPasscodeViewController.h"
#import "RCHelper.h"
#import "RCWebEngine.h"
#import "YourPracticeAppDelegate.h"
#import "PopoverView.h"
#import "Logic.h"
#import "MBProgressHUD.h"
#import "AboutUsViewController.h"
#import "RCSessionEngine.h"
#import "RCPracticeHelper.h"
@interface CreatePINViewController : UIViewController<PAPasscodeViewControllerDelegate,WebEngineDelegate,PopoverViewDelegate,UpdateDownloadStarterDelegate,SubMenuDelegate,DownloaderDelegate,MBProgressHUDDelegate,SessionEngineDelegate>
{
    Logic *logic;
    MBProgressHUD *statusHUD;
}
@property (strong,nonatomic) RCHelper *registerHelper;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *createPin;


#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading;
- (void)switchToIndeterminate;
- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status;
- (void)updateProgress:(DownloadStatus *)status;
- (void)didFinish;
- (void)hasFailed;

@end
