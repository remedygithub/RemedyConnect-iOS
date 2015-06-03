//
//  ProviderHomeViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 08/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macros.h"
#import "PopoverView.h"
#import "RCHelper.h"
#import "AboutUsViewController.h"
#import "FileDownloader.h"
#import "NetworkViewController.h"
#import "MBProgressHUD.h"
#import "Logic.h"
#import "RCSessionEngine.h"
#import "RCPracticeHelper.h"
#import "RCWebEngine.h"
#import "SessionTime.h"
#import "ProviderLoginViewController.h"

@interface ProviderHomeViewController : UIViewController<PopoverViewDelegate,DownloaderDelegate,NetworkDelegate,MBProgressHUDDelegate,UpdateDownloadStarterDelegate,MainMenuDelegate,DownloaderDelegate,SubMenuDelegate,SessionEngineDelegate,WebEngineDelegate>
{
    MBProgressHUD *statusHUD;
    Logic *logic;
    NSString *practiceName;
    SessionTime *timeSession;

}
@property (nonatomic, strong) RCHelper *messageHelper;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *adminBtn;
@property (strong, nonatomic) IBOutlet UILabel *messageCountLabel;
@property (strong, nonatomic) UIImageView *village;
@property (strong, nonatomic) UIWindow *window;


#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading;
- (void)switchToIndeterminate;
- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status;
- (void)updateProgress:(DownloadStatus *)status;
- (void)didFinish;
- (void)hasFailed;

@end
