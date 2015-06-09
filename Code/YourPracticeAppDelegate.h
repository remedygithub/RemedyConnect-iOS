//
//  GPAppDelegate.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.02..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALActivityIndicatorView.h"
#import "SessionTime.h"
#import "PAPasscodeViewController.h"
#import "MessageListViewController.h"
#import "ProviderLoginViewController.h"
#import "RCHelper.h"
#import "RCPracticeHelper.h"
#import "Macros.h"
#import <PushIOManager/PushIOManager.h>
#import "ProviderHomeViewController.h"


@interface YourPracticeAppDelegate : UIResponder <UIApplicationDelegate,PAPasscodeViewControllerDelegate,PushIOManagerDelegate>
{
    ALActivityIndicatorView *m_cActivityIndicator;
    PAPasscodeViewController *passcode;
    NSString *deviceTokenStr;
}


@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSDictionary *launchDict;


//Methods for showing activity indicators
-(void)applicationDidTimeout;
-(void)startActivity;
-(void)stopActivity;
-(void)logOut;


@end
