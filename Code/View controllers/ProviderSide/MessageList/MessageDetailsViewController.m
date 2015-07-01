//
//  MessageDetailsViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 23/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "MessageDetailsViewController.h"
@interface MessageDetailsViewController ()
@property (nonatomic, strong)PopoverView *mPopver;

@end

@implementation MessageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.scrollView.backgroundColor = [UIColor whiteColor];
    logic = [Logic sharedLogic];

    NSString *messageDetail = [[NSUserDefaults standardUserDefaults]objectForKey:@"Details"];
    self.messageDetails.text = messageDetail;
    
    NSString *cellNumber = [[NSUserDefaults standardUserDefaults]objectForKey:@"phoneNumber"];
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    NSLog(@"phone Number %@", cellNumber);
    self.phoneLabel.attributedText = [[NSAttributedString alloc] initWithString:cellNumber attributes:underlineAttribute];
    
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([self class]) forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self displayImages];
    [self getUserLoginSession];
}



-(void)getUserLoginSession
{
    [RCPinEngine SharedWebEngine].delegate = self;
    [[RCPinEngine SharedWebEngine]checkLoginSessionOfUser];
}

-(void)checkReadOrUnreadMessage
{
    [RCWebEngine SharedWebEngine].delegate = self;
    [[RCWebEngine SharedWebEngine] CheckMessageReadOrUnread];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"BackToList"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)appEnteredForeground
{
    [[UIApplication sharedApplication].delegate performSelector:@selector(applicationDidTimeout)];
}

- (IBAction)backBtnTapped:(id)sender
{
    BOOL Back = [[NSUserDefaults standardUserDefaults]objectForKey:@"BackToList"];
    if (Back)
    {
        [RCHelper SharedHelper].isFromDetailMessage = YES;
        UIViewController *controller =  [self.storyboard instantiateViewControllerWithIdentifier:@"MessageListViewController"];
        [self.navigationController pushViewController:controller animated:NO];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"BackToList"];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)menuBtnTapped:(id)sender
{
    CGPoint point = CGPointMake(self.menuBtn.frame.origin.x + self.menuBtn.frame.size.width / 2,
                                self.menuBtn.frame.origin.y + self.menuBtn.frame.size.height);
//    [PopoverView showPopoverAtPoint:point
//                             inView:self.view
//                    withStringArray:[NSArray arrayWithObjects:@"Refresh",
//                                     @"Choose Your Practice", @"Legal",@"Logout",@"Patient/Guardian",nil]
//                           delegate:self];
    
    if (_mPopver) {
        [_mPopver removeFromSuperview];
        _mPopver = nil;
    }
    _mPopver= [[PopoverView alloc] initWithFrame:CGRectZero];
    [_mPopver showAtPoint:point inView:self.view withStringArray:[NSArray arrayWithObjects:@"Refresh",@"Choose Your Practice", @"Legal",@"Logout",@"Patient/Guardian",nil]];
    _mPopver.delegate = self;
}


-(void)LogoutTheUser
{
    
    if ([RCPracticeHelper SharedHelper].isLogout || [RCPracticeHelper SharedHelper].isPinFailureAttempt || [RCPracticeHelper SharedHelper].isLoginTimeOut)
    {
        [self hasStartedDownloading:@"Logging Out..."];
    }
    [RCSessionEngine SharedWebEngine].delegate = self;
    [[RCSessionEngine SharedWebEngine] LogoutTheUser];
}

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    NSString * praticeName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nameOfPratice"];
    NSLog(@"%@",praticeName);
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
                 [RCPracticeHelper SharedHelper].isChangePractice =YES;
                 [RCPracticeHelper SharedHelper].isLogout =NO;
                 [RCPracticeHelper SharedHelper].isApplicationMode =NO;
                 [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
                 [RCPracticeHelper SharedHelper].isLoginTimeOut = NO;
                 [self LogoutTheUser];
                 break;
            
        case 2:
            [self performSegueWithIdentifier:@"MoveFromMsgDetailToTerms" sender:self];
            break;
            
//        case 3:
//            [self performSegueWithIdentifier:@"MoveFromMsgDetailToAbout" sender:self];
//            break;
            
        case 3:
                [RCPracticeHelper SharedHelper].isChangePractice =NO;
                [RCPracticeHelper SharedHelper].isLogout =YES;
                [RCPracticeHelper SharedHelper].isApplicationMode =NO;
                [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
                [RCPracticeHelper SharedHelper].isLoginTimeOut = NO;
                [self LogoutTheUser];
                break;
    
        case 4:
                [RCPracticeHelper SharedHelper].isChangePractice =NO;
                [RCPracticeHelper SharedHelper].isLogout =NO;
                [RCPracticeHelper SharedHelper].isApplicationMode = YES;
                [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
                [RCPracticeHelper SharedHelper].isLoginTimeOut = NO;
                [self LogoutTheUser];
                break;
            
        default:
            break;
            
    }
    [popoverView dismiss:TRUE];
    if (_mPopver)
    {
        [_mPopver removeFromSuperview];
        _mPopver = nil;
    }
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    if (_mPopver)
    {
        [_mPopver removeFromSuperview];
        _mPopver = nil;
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MoveFromMsgDetailToTerms"])
    {
        AboutUsViewController *aboutController = [segue destinationViewController];
        aboutController.self.Text = @"Legal";
    }
    if ([segue.identifier isEqualToString:@"MoveFromMsgDetailToAbout"])
    {
        AboutUsViewController *termsController = [segue destinationViewController];
        termsController.self.Text = @"About";
    }
}


- (IBAction)phoneNumBtnTapped:(id)sender
{
    NSString *phoneNumber = self.messageDetailHelper.phoneNumber;
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSLog(@"%@",cleanedString);
    
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cleanedString]];
    
    NSLog(@"making call with %@",telURL);
    [[UIApplication sharedApplication] openURL:telURL];
}


-(void)displayImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
   
    NSString *logoimageFilePath = [unzipPath stringByAppendingPathComponent:@"logo.png"];
    NSData *logoimageData = [NSData dataWithContentsOfFile:logoimageFilePath options:0 error:nil];
    UIImage *logoimg = [UIImage imageWithData:logoimageData];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       self.logoImage.image = logoimg;
                   });
}



#pragma mark - HUD handling
- (void)hudWasHidden:(MBProgressHUD *)hud {
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


#pragma mark - PinEngine Delegate
-(void)PinManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    if ([[pResultDict objectForKey:@"successfull"]integerValue])
    {
        if (self.isFromCheckMessage)
        {
            NSString * messageCount = [NSString stringWithFormat:@"%@",[pResultDict objectForKey:@"count"]];
            NSLog(@"Damm %@",messageCount);
            [UIApplication sharedApplication].applicationIconBadgeNumber = [messageCount integerValue];
            [[NSUserDefaults standardUserDefaults] setInteger:[messageCount integerValue] forKey:@"BadgeCount"];;
            self.isFromCheckMessage = NO;
        }
        else
        {
            [self checkReadOrUnreadMessage];
        }
        
    }
    else
    {
        [RCPracticeHelper SharedHelper].isChangePractice =NO;
        [RCPracticeHelper SharedHelper].isLogout =NO;
        [RCPracticeHelper SharedHelper].isApplicationMode = NO;
        [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
        [RCPracticeHelper SharedHelper].isLoginTimeOut = YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Your session has expired" message:@"You will need to login again. Please press OK to proceed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 10;
        [alert show];
    }
}



-(void)PinManagerDidFailWithError:(NSError *)error
{
    [statusHUD hide:YES afterDelay:2];
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10 && buttonIndex == 0)
    {
        [self LogoutTheUser];
    }
}

-(void)clearData
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - SessionManager delegate
-(void)SessionManagerDidReceiveResponse:(NSDictionary*)pResultDict
{
    [statusHUD hide:YES afterDelay:1];
    if ([[pResultDict objectForKey:@"success"]boolValue])
    {
        if ([RCPracticeHelper SharedHelper].isChangePractice)
        {
            [self clearData];
            [RCHelper SharedHelper].pinCreated = NO;
            NSMutableDictionary *userDict = [[RCHelper SharedHelper] getLoggedInUser];
            [[RCHelper SharedHelper] setUserWithUserName:[userDict valueForKey:kUserName] andPin:nil andLoggedIN:YES];
            [self performSegueWithIdentifier:@"MoveToMessageDetailToSearch" sender:self];
        }
        else if ([RCPracticeHelper SharedHelper].isLogout)
        {
            [self clearData];
            NSMutableDictionary *userDict = [[RCHelper SharedHelper] getLoggedInUser];
            [[RCHelper SharedHelper] setUserWithUserName:[userDict valueForKey:kUserName] andPin:[userDict valueForKey:kSecretPin] andLoggedIN:NO];
            [self moveToLoginController];
        }
        else if ([RCPracticeHelper SharedHelper].isApplicationMode)
        {
            [self clearData];
            NSMutableDictionary *userDict = [[RCHelper SharedHelper] getLoggedInUser];
            [[RCHelper SharedHelper] setUserWithUserName:[userDict valueForKey:kUserName] andPin:[userDict valueForKey:kSecretPin] andLoggedIN:NO];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else if ([RCPracticeHelper SharedHelper].isPinFailureAttempt)
        {
            [RCHelper SharedHelper].pinCreated = NO;
            NSMutableDictionary *userDict = [[RCHelper SharedHelper] getLoggedInUser];
            [[RCHelper SharedHelper] setUserWithUserName:[userDict valueForKey:kUserName] andPin:nil andLoggedIN:YES];
            [self moveToLoginController];
        }
        else if ([RCPracticeHelper SharedHelper].isLoginTimeOut)
        {
            NSMutableDictionary *userDict = [[RCHelper SharedHelper] getLoggedInUser];
            [[RCHelper SharedHelper] setUserWithUserName:[userDict valueForKey:kUserName] andPin:[userDict valueForKey:kSecretPin] andLoggedIN:NO];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"responseToken"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self moveToLoginController];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutNotification object:nil];
        }
    }
}


-(void)moveToLoginController
{
    NSArray *arrayOfControllers = [self.navigationController viewControllers];
    //Checking whether viewcontroller exist
    for (id controller in arrayOfControllers)
    {
        if ([controller isKindOfClass:[ProviderLoginViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    UIViewController *controller =  [self.storyboard instantiateViewControllerWithIdentifier:@"ProviderLoginViewController"];
    [self.navigationController pushViewController:controller animated:NO];
}

-(void)SessionManagerDidFailWithError:(NSError *)error
{
    [statusHUD hide:YES afterDelay:2];
    
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}



#pragma MARK-Web Delegate Methods
-(void)connectionManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    if ([[pResultDict objectForKey:@"successfull"]integerValue])
    {
       //Message read
         self.isFromCheckMessage = YES;
        [self getUserLoginSession];
    }
}

-(void)connectionManagerDidFailWithError:(NSError *)error
{
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}


//Checking for device Orientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (_mPopver)
    {
        [self menuBtnTapped:nil];
    }
    
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
    }
    else
    {
        NSLog(@"Portrait");
    }
}

@end
