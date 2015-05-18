//
//  PushIONewsViewController.m
//  news
//
//  Copyright (c) 2013 Push IO Inc. All rights reserved.
//

#import "PushIONewsViewController.h"
#import <PushIOManager/PushIOManager.h>

@interface PushIONewsViewController ()

@end

@implementation PushIONewsViewController
@synthesize allSwitch = _allSwitch;
@synthesize usSwitch = _usSwitch;
@synthesize sportsSwitch = _sportsSwitch;


- (void)configureSwitches:(BOOL)yesOrNo
{
    _usSwitch.enabled = yesOrNo;
    _sportsSwitch.enabled = yesOrNo;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _allSwitch.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"PIONews_All"] boolValue];
    
    if (_allSwitch.on == YES)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeNewsstandContentAvailability];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    }
    
    _usSwitch.on = [[PushIOManager sharedInstance] isRegisteredForCategory:@"US"];
    _sportsSwitch.on = [[PushIOManager sharedInstance] isRegisteredForCategory:@"Sports"];
    
    [self configureSwitches:_allSwitch.on];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)switchAction:(id)sender
{
    UISwitch *mySwitch = (UISwitch *)sender;
    
    if (sender == _allSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:_allSwitch.on forKey:@"PIONews_All"];
        
        if (_allSwitch.on == NO)
        {
            [[PushIOManager sharedInstance] unregisterFromPushIO];
            _usSwitch.on = NO;
            _sportsSwitch.on = NO;
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeNewsstandContentAvailability];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
        }
            
        [self configureSwitches:_allSwitch.on];
    }
    else if (sender == _usSwitch)
    {
        if (mySwitch.on == YES)
            [[PushIOManager sharedInstance] registerCategory:@"US"];
        else
            [[PushIOManager sharedInstance] unregisterCategory:@"US"];
    }
    else if (sender == _sportsSwitch)
    {
        if (mySwitch.on == YES)
            [[PushIOManager sharedInstance] registerCategory:@"Sports"];
        else
            [[PushIOManager sharedInstance] unregisterCategory:@"Sports"];
    }
}
@end
