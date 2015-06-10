//
//  MessageDetailsViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 23/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNGridMenu.h"
#import "Macros.h"
#import "RCHelper.h"
#import "PopoverView.h"
#import "Logic.h"
#import "MBProgressHUD.h"
#import "NetworkViewController.h"
#import "AboutUsViewController.h"
#import "RCPinEngine.h"
#import "RCPracticeHelper.h"
#import "RCSessionEngine.h"
#import "ProviderLoginViewController.h"
#import "RCWebEngine.h"

@interface MessageDetailsViewController : UIViewController<RNGridMenuDelegate,PopoverViewDelegate,UpdateDownloadStarterDelegate,MainMenuDelegate,DownloaderDelegate,SubMenuDelegate,NetworkDelegate,PinEngineDelegate,SessionEngineDelegate,MBProgressHUDDelegate,WebEngineDelegate>
{
    RCHelper *messageHelper;
    Logic *logic;
    MBProgressHUD *statusHUD;
}
@property (strong, nonatomic) RCHelper *messageDetailHelper;
@property (strong, nonatomic) NSString *attributePhoneString;
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (strong, nonatomic) IBOutlet UITextView *messageDetails;
@property (strong, nonatomic) IBOutlet UIButton *phoneNumBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UIButton *menuBtn;

@end
