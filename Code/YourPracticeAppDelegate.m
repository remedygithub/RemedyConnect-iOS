//
//  GPAppDelegate.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.02..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "YourPracticeAppDelegate.h"
//#import "TestFlight.h"
#import "TestFairy.h"
#import "ReachabilityManager.h"
#import "RCHelper.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation YourPracticeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ReachabilityManager sharedManager];
    
    // Override point for customization after application launch.
    //[TestFlight takeOff:@"f32c392f-6402-4d49-8487-d4094af55544"];
    
    [TestFairy begin:@"7f6f0f7e226f59d3b1a2ae5446b11a5b2427a176"];
    // Differentiate between ios 8 and ios 7,6 push notification registration
    if(IS_OS_8_OR_LATER)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else
    {
        //register to receive notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
//
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout) name:kApplicationDidTimeoutNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(PAPasscodeViewControllerDidCancel:)
                                                 name:kResetPinNotification
                                               object:nil];
    
    [[PushIOManager sharedInstance] setDelegate:self];
    [[PushIOManager sharedInstance] didFinishLaunchingWithOptions:launchOptions];
    return YES;
}



- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    
        if ([RCHelper SharedHelper].isPassCodeView)
        {
            return UIInterfaceOrientationMaskPortrait;
        }
        else
            return UIInterfaceOrientationMaskAll;
        
}



//-(void)startLoginSession
//{
//    [RCHelper SharedHelper].fromLoginTimeout = YES;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidLoginTimeout:) name:kApplicationDidLoginTimeoutNotification object:nil];
//}


- (void)applicationDidTimeout
{
    NSLog (@"time exceeded!!");
    //PAPasscodeViewController* passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
    NSString *pinString = [[NSUserDefaults standardUserDefaults] valueForKey:@"screatKey"];
    
    UIViewController *vc = [self visibleViewController:[UIApplication sharedApplication].keyWindow.rootViewController];

    if (!pinString || ![vc isKindOfClass:[ProviderHomeViewController class]] )
    {
        return;
    }
    
    if (passcode)
    {
        [passcode.view removeFromSuperview];
        [passcode removeFromParentViewController];
        passcode = nil;
    }
    passcode = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        passcode.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcode.delegate = self;
    [[self window] addSubview:passcode.view];
    [[self window] bringSubviewToFront:passcode.view];
}



- (UIViewController *)visibleViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        
        return [self visibleViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    
    return [self visibleViewController:presentedViewController];
}

#pragma mark Push Notification Methods
//Here we are taking and saving the "Device Token" of the device
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Device Token: %@", deviceToken);
    [[PushIOManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    //Convert device token to machine readable format from human readable format
    self.deviceID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    NSLog(@"%@", self.deviceID);
    [[NSUserDefaults standardUserDefaults] setObject:self.deviceID forKey:@"uniqueID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    deviceTokenStr = [[[deviceToken description]
                       stringByReplacingOccurrencesOfString: @"<" withString: @""]
                      stringByReplacingOccurrencesOfString: @">" withString: @""];
    NSLog(@"My token is: %@", deviceTokenStr);
    //Store the token in the main bundle
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:APNS_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[PushIOManager sharedInstance] didReceiveRemoteNotification:userInfo];
}

//Failure case for remote notification.
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    deviceTokenStr = nil;
    [[PushIOManager sharedInstance] didFailToRegisterForRemoteNotificationsWithError:err];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APNS_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Error in registration
    NSLog(@"Failed to get device token: %@",err);
}




- (void)readyForRegistration
{
    // If this method is called back, PushIOManager has a proper device token
    // so now you are ready to register.
    [[PushIOManager sharedInstance] registerWithPushIO];
}

- (void)registrationSucceeded
{
    // Push IO registration was successful
    NSLog(@"Successfull");
    
}

- (void)registrationFailedWithError:(NSError *)error statusCode:(int)statusCode
{
    // Push IO registration failed
    NSLog(@"Failed");
}

#pragma Screat PIN Checking Delegate Methods
- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller
{
    //[self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    if (passcode)
    {
        [passcode.view removeFromSuperview];
        [passcode removeFromParentViewController];
         passcode = nil;
       
    }
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
    if (passcode)
    {
        [passcode.view removeFromSuperview];
        [passcode removeFromParentViewController];
        passcode = nil;
    }

    // [self dismissViewControllerAnimated:YES completion:^()
//    [self.window.rootViewController dismissViewControllerAnimated:YES completion:^()
//     {
//         [[[UIAlertView alloc] initWithTitle:nil message:@"Pin entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//     }];
}

-(void)PAPasscodeViewControllerDidResetPasscode:(PAPasscodeViewController *)controller
{
    
    if (passcode)
    {
        [passcode.view removeFromSuperview];
        [passcode removeFromParentViewController];
        passcode = nil;
        
        [RCHelper SharedHelper].pinCreated =  NO;
        
        //        PAPasscodeViewController* passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
        passcode = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            passcode.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        }
        passcode.delegate = self;
    }
//    [self.window.rootViewController dismissViewControllerAnimated:YES completion:^()
//     {
//         [RCHelper SharedHelper].pinCreated =  NO;
//         
//         //        PAPasscodeViewController* passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
//         passcode = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
//         
//         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//         {
//             passcode.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
//         }
//         passcode.delegate = self;
//         [self.window.rootViewController presentViewController:passcode animated:YES completion:nil];
//     }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
    if (passcode)
    {
        NSLog(@"%@",controller.passcode);
        [RCHelper SharedHelper].pinCreated = YES;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:controller.passcode forKey:@"screatKey"];
        [defaults synchronize];
        [passcode.view removeFromSuperview];
        [passcode removeFromParentViewController];
        passcode = nil;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"Active");
    if ([RCHelper SharedHelper].pinCreated)
    {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
    }
   
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark Activity Indicator Methods
-(void)startActivity
{
    if(m_cActivityIndicator == nil)
        m_cActivityIndicator = [[ALActivityIndicatorView alloc] initWithFrame:self.window.frame];
    
    [m_cActivityIndicator startAnimating];
    [[self window] addSubview:m_cActivityIndicator];
    [[self window] bringSubviewToFront:m_cActivityIndicator];
}

-(void)stopActivity
{
    [m_cActivityIndicator stopAnimating];
}


@end
