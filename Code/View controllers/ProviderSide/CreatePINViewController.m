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
    [[UIApplication sharedApplication].delegate performSelector:@selector(startActivity)];
    [[RCWebEngine SharedWebEngine] sendRequestForRegister:practieID Physician:physicanID device:hashUserString];
    [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:@"you've been logged in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
    
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
                                     @"Choose Your Practice", @"Terms and Conditions",@"About",@"Logout",nil]
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
                [logic setUpdateDownloadStarterDelegate:self];
                [logic handleActionWithTag:index shouldProceedToPage:FALSE];
            }
            break;
        case 1:
            //            if ([RCHelper SharedHelper].fromAgainList)
            //            {
            //                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
            //            }
            //            else
            //            {
            //                //[logic setMainMenuDelegate:self];
            //                [RCHelper SharedHelper].menuToArticle = YES;
            //                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
            //            }
            [self performSegueWithIdentifier:@"FromPinToSearch" sender:self];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"FromPinToTerms" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"FromPinToAbout" sender:self];
            break;
            
        case 4:
            [RCSessionEngine SharedWebEngine].delegate = self;
            [self hasStartedDownloading:@"Logging Out..."];
            [[RCSessionEngine SharedWebEngine] LogoutTheUser];
            break;
            
        default:
            break;
    }
    [popoverView dismiss:TRUE];
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
        // [self performSegueWithIdentifier:@"MoveToProviderFromPin" sender:self];
         [self performSegueWithIdentifier:@"UnderDev" sender:self];
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
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Forgot your PIN?" delegate:nil cancelButtonTitle:@"Reset your PIN" otherButtonTitles:nil];
         [alert show];
     }];
  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
}

-(void)SessionManagerDidFailWithError:(NSError *)error
{
    
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
