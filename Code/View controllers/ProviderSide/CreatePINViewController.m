//
//  CreatePINViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 08/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "CreatePINViewController.h"
#import "NSString+MD5.h"
#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@interface CreatePINViewController ()

@end

@implementation CreatePINViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    NSString *practieID = self.registerHelper.practiceID;
    NSString *physicanID = self.registerHelper.PhysicianID;
 
    NSString *userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"user"];
    NSLog(@"%@",userName);
    //Encrypting the Username into Hash value (Message-Digest MD5)
    NSString *hashUserString = [userName MD5];
    NSLog(@"%@",hashUserString);
    logic = [Logic sharedLogic];

    
    [RCWebEngine SharedWebEngine].delegate = self;
    [[RCWebEngine SharedWebEngine] sendRequestForRegister:practieID Physician:physicanID device:hashUserString];
    
    
    [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    if ([RCHelper SharedHelper].isLogin)
    {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:@"You've been logged in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlert show];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([self class]) forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)menuBtnTapped:(id)sender
{
    CGPoint point = CGPointMake(self.menuBtn.frame.origin.x + self.menuBtn.frame.size.width / 2,
                                self.menuBtn.frame.origin.y + self.menuBtn.frame.size.height);
    [PopoverView showPopoverAtPoint:point
                             inView:self.view
                    withStringArray:[NSArray arrayWithObjects:@"Update Your Practice Info",
                                     @"Choose Your Practice", @"Terms and Conditions",@"About Us",@"Logout",@"Change application mode",nil]
                           delegate:self];
    [logic setUpdateDownloadStarterDelegate:self];
}




- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    NSString * praticeName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nameOfPratice"];
    NSLog(@"%@",praticeName);
    //NSString  * searchPraticeString =[[RCHelper SharedHelper] getSearchURLByName:praticeName];
    switch (index)
    {
        case 0:
            if ([NetworkViewController SharedWebEngine].NetworkConnectionCheck)
            {
                [RCHelper SharedHelper].isLogin = NO;
                [logic setUpdateDownloadStarterDelegate:self];
                [logic handleActionWithTag:index shouldProceedToPage:FALSE];
            }
            break;
        case 1:
          
            [RCHelper SharedHelper].isLogin = NO;
            [RCPracticeHelper SharedHelper].isChangePractice =YES;
            [RCPracticeHelper SharedHelper].isLogout =NO;
            [RCPracticeHelper SharedHelper].isApplicationMode =NO;
            [self LogoutTheUser];

            break;
            
        case 2:
            [self performSegueWithIdentifier:@"FromPinToTerms" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"FromPinToAbout" sender:self];
            break;
            
        case 4:
            [RCPracticeHelper SharedHelper].isChangePractice =NO;
            [RCPracticeHelper SharedHelper].isLogout =YES;
            [RCPracticeHelper SharedHelper].isApplicationMode =NO;
            [self LogoutTheUser];
            break;
            
        case 5:
            [RCPracticeHelper SharedHelper].isChangePractice =NO;
            [RCPracticeHelper SharedHelper].isLogout =NO;
            [RCPracticeHelper SharedHelper].isApplicationMode = YES;
            [self LogoutTheUser];
            break;
            
        default:
            break;
    }
    [popoverView dismiss:TRUE];
}


-(void)LogoutTheUser
{
    [RCSessionEngine SharedWebEngine].delegate = self;
    if ([RCPracticeHelper SharedHelper].isLogout)
    {
        [self hasStartedDownloading:@"Logging Out..."];
    }
    [[RCSessionEngine SharedWebEngine] LogoutTheUser];
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

- (IBAction)createPinBtnTapped:(id)sender
{
    [self setCreatePinAndVerfiyPinView];
}

-(void)setCreatePinAndVerfiyPinView
{
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    passcodeViewController.delegate = self;
    [self presentViewController:passcodeViewController animated:YES completion:nil];
}



#pragma mark - PAPasscodeViewControllerDelegate

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
   // [self performSelector:@selector(moveBackToCreatePin) withObject:nil afterDelay:0.5];
}

-(void)moveBackToCreatePin
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)PAPasscodeViewControllerDidEnterAlternativePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Alternative Pin entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Pin entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^()
     {
         NSLog(@"%@",controller.passcode);
         [RCHelper SharedHelper].pinCreated = YES;
          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         [defaults setObject:controller.passcode forKey:@"screatKey"];
         [defaults synchronize];
         [self performSegueWithIdentifier:@"MoveToProviderFromPin" sender:self];
     }];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^()
     {
     }];
}


-(void)PAPasscodeViewControllerDidResetPasscode:(PAPasscodeViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^()
     {
         [RCHelper SharedHelper].pinCreated =  NO;
         
         PAPasscodeViewController* passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
         
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
         {
             passcodeViewController.backgroundView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
         }
         passcodeViewController.delegate = self;
         [self presentViewController:passcodeViewController animated:YES completion:nil];
     }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)clearData
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


-(void)connectionManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    [[UIApplication sharedApplication].delegate performSelector:@selector(stopActivity)];
}

-(void)connectionManagerDidFailWithError:(NSError *)error
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopActivity)];
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}

-(void)SessionManagerDidReceiveResponse:(NSDictionary*)pResultDict
{
    [statusHUD hide:YES afterDelay:2];
    if ([[pResultDict objectForKey:@"success"]boolValue])
    {
        if ([RCPracticeHelper SharedHelper].isChangePractice)
        {
            [self clearData];
            [self performSegueWithIdentifier:@"FromPinToSearch" sender:self];
        }
        else if ([RCPracticeHelper SharedHelper].isLogout)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([RCPracticeHelper SharedHelper].isApplicationMode)
        {
            [self clearData];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

-(void)SessionManagerDidFailWithError:(NSError *)error
{
    [statusHUD hide:YES afterDelay:2];
    
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FromPinToTerms"])
    {
        AboutUsViewController *termsController = [segue destinationViewController];
        termsController.self.Text = @"Terms and Conditions";
    }
    if ([segue.identifier isEqualToString:@"FromPinToAbout"])
    {
        AboutUsViewController *aboutController = [segue destinationViewController];
        aboutController.self.Text = @"About";
    }
}

#pragma mark - HUD handling
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [statusHUD removeFromSuperview];
    statusHUD = nil;
}

#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading
{
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD setLabelText:@"Starting download..."];
}

- (void)switchToIndeterminate
{
    [statusHUD setMode:MBProgressHUDModeIndeterminate];
}

- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status
{
    [statusHUD setLabelText:@"Downloading..."];
}

- (void)updateProgress:(DownloadStatus *)status
{
    if ([status expectedLength] > 0)
    {
        statusHUD.progress = [status currentLength] / (float)[status expectedLength];
    }
}

- (void)didFinish {
    [statusHUD setMode:MBProgressHUDModeText];
    [statusHUD setLabelText:@"Finished!"];
    [statusHUD hide:YES afterDelay:2];
    // We have to reload the data:
    [logic resetAfterUpdate];
    [self viewDidLoad];
}

- (void)hasFailed {
    [statusHUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to download files"
                                                    message:@"Please check your internet connection and try again."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [logic resetAfterUpdate];
}
@end
