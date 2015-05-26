//
//  UnderDevViewController.m
//  YourPractice
//
//  Created by Ravindra Kishan on 21/05/15.
//  Copyright (c) 2015 NewPush LLC. All rights reserved.
//

#import "UnderDevViewController.h"

@interface UnderDevViewController ()

@end

@implementation UnderDevViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:@"PIN has been set successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
   // [self checkSessionTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkSessionTime];
}

- (IBAction)backBtnTapped:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
     NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
    
}

-(void)checkSessionTime
{
    NSString *deviceResponseToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"responseToken"];
    NSString *practiceId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userPracticeId"];
    NSLog(@"%@",deviceResponseToken);
    NSLog(@"%@",practiceId);
    if (deviceResponseToken && practiceId)
    {
        NSLog(@"Token Edey");
        [RCWebEngine SharedWebEngine].delegate = self;
        [self hasStartedDownloading:@"Checking Session.."];
        [RCWebEngine SharedWebEngine].getLoginInTimeOutDetails;
    }
}


- (void)hasStartedDownloading:(NSString *)processString
{
    if (nil != statusHUD)
    {
        [statusHUD hide:TRUE];
    }
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD show:YES];
    [statusHUD setLabelText:processString];
    [self.view bringSubviewToFront:statusHUD];
}



#pragma mark - connection Delegate
-(void)connectionManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    [statusHUD hide:YES afterDelay:2];
    if ([[pResultDict objectForKey:@"successfull"]integerValue])
    {
        NSString *timeOutHour = [pResultDict objectForKey:@"loginTimeoutHours"];

        NSLog(@"%@",timeOutHour);
        if (timeOutHour > 0)
        {
            //Stay Here
            NSLog(@"No Tata");
        }
        else
        {
            NSArray *array = [self.navigationController viewControllers];
            [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
        }
    }
}

-(void)connectionManagerDidFailWithError:(NSError *)error
{
    [statusHUD hide:YES afterDelay:2];
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Couldn't log you in" message:@"Unknown username or bad password - please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}




@end
