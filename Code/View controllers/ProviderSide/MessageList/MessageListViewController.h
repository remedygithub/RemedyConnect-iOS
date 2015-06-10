//
//  MessageListViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 09/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageDetailsViewController.h"
#import "RCHelper.h"
#import "PopoverView.h"
#import "Logic.h"
#import "MBProgressHUD.h"
#import "NetworkViewController.h"
#import "AboutUsViewController.h"
#import "MessageListCell.h"
#import "RCWebEngine.h"
#import "RCPracticeHelper.h"
#import "RCSessionEngine.h"
#import "ProviderHomeViewController.h"
#import "RCPinEngine.h"

@interface MessageListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PopoverViewDelegate,MBProgressHUDDelegate,UpdateDownloadStarterDelegate,MainMenuDelegate,DownloaderDelegate,SubMenuDelegate,NetworkDelegate,WebEngineDelegate,SessionEngineDelegate,PinEngineDelegate>
{
    RCHelper *messageHelper;
    Logic *logic;
    MBProgressHUD *statusHUD;
}
@property (strong, nonatomic) IBOutlet UITableView *messageTableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) IBOutlet UIButton *menuBtn;
@end
