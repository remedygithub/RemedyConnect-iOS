//
//  PushIONewsAppDelegate.m
//  news
//
//  Copyright (c) 2013 Push IO Inc. All rights reserved.
//

#import "PushIONewsAppDelegate.h"

@implementation PushIONewsAppDelegate

#pragma mark Application Lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[PushIOManager sharedInstance] setDelegate:self];
    [[PushIOManager sharedInstance] didFinishLaunchingWithOptions:launchOptions];
    [[PushIOManager sharedInstance] setDebugLevel:PUSHIO_DEBUG_VERBOSE];
    
    
    BOOL pushEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"PIONews_All"] boolValue];
    
    if (pushEnabled == YES)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeNewsstandContentAvailability];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    }
    
    return YES;
}

#pragma mark APNS

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[PushIOManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[PushIOManager sharedInstance] didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[PushIOManager sharedInstance] didReceiveRemoteNotification:userInfo];
    
    // Present the push notification via an AlertView if received when the app is running
    NSDictionary *payload = [userInfo objectForKey:@"aps"];
    NSString *alertMessage = [payload objectForKey:@"alert"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


#pragma mark Push IO

- (void) readyForRegistration
{
    NSLog(@"Push IO is ready for registration");
    
    // This will register for broadcast. Alternatively, register for categories to segment.
    [[PushIOManager sharedInstance] registerWithPushIO];
}

- (void)registrationSucceeded
{
    NSLog(@"Push IO registration succeeded");
}

- (void)registrationFailedWithError:(NSError *)error statusCode:(int)statusCode
{
    NSLog(@"Push IO registration failed");
}

- (void)newNewsstandContentAvailable
{
    // Start your content download here.
    NSLog(@"Push IO new newstand content available");
}


@end
