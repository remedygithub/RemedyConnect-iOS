//
//  ProviderHomeViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 08/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "ProviderHomeViewController.h"
#define AdminTest   @"https://webteleservicestest.remedyconnect.com/Default.aspx?ReturnUrl=%2fPractice%2fInformation%2fMainOffice.aspx"
#define AdminProd   @"https://admin.remedyoncall.com/Default.aspx?ReturnUrl=%2f"
#define adminUrl   AdminProd
@interface ProviderHomeViewController ()
@property (nonatomic, strong)PopoverView *mPopver;
@end

@implementation ProviderHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    practiceName = [[NSUserDefaults standardUserDefaults]objectForKey:@"nameOfPratice"];

    logic = [Logic sharedLogic];
    [self displayImages];
    [self roundedLabelUI];

    NSArray *arrayOfControllers = [self.navigationController viewControllers];
    if (arrayOfControllers.count == 2)
    {
        [self appEnteredForeground];
    }
    else
    {
        [self checkUserUnreadMessageCount];
    }
    
    
    self.messageCountLabel.hidden = YES;
    //[self assignMessageCountValue];
    
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([self class]) forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetAction)
                                                 name:kResetPinNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(assignMessageCountValue)
                                                 name:kNewArrivedMessageCount
                                               object:nil];
}



-(void)resetAction
{
    [RCPracticeHelper SharedHelper].isChangePractice = NO;
    [RCPracticeHelper SharedHelper].isLogout =NO;
    [RCPracticeHelper SharedHelper].isApplicationMode =NO;
    [RCPracticeHelper SharedHelper].isPinFailureAttempt = YES;
    [RCPracticeHelper SharedHelper].isLoginTimeOut = NO;
    [self LogoutTheUser];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)checkUserUnreadMessageCount
{
    [RCWebEngine SharedWebEngine].delegate = self;
    [[RCWebEngine SharedWebEngine] checkUserUnreadMessages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.messageCountLabel.hidden = YES;

    [self checkUserUnreadMessageCount];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.navigationController setNavigationBarHidden:YES];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appEnteredForeground
{
    [self roundedLabelUI];
    [self checkUserUnreadMessageCount];
    [[UIApplication sharedApplication].delegate performSelector:@selector(applicationDidTimeout)];
}

-(void)roundedLabelUI
{
    self.messageCountLabel.layer.cornerRadius = 19.0f;
    self.messageCountLabel.layer.masksToBounds = YES;
}


- (IBAction)messageBtnTapped:(id)sender
{
    [self performSegueWithIdentifier:@"MoveToViewMessageList" sender:self];
}


- (IBAction)adminBtnTapped:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adminUrl]];
}


-(void)displayImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    NSString *imageFilePath = [unzipPath stringByAppendingPathComponent:@"background.png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
    UIImage *img = [UIImage imageWithData:imageData];
    
    NSString *logoimageFilePath = [unzipPath stringByAppendingPathComponent:@"menulogo.png"];
    NSData *logoimageData = [NSData dataWithContentsOfFile:logoimageFilePath options:0 error:nil];
    UIImage *logoimg = [UIImage imageWithData:logoimageData];
    
    NSString *menuFilePath = [unzipPath stringByAppendingPathComponent:@"button.9.png"];
    NSData *menuimageData = [NSData dataWithContentsOfFile:menuFilePath options:0 error:nil];
    UIImage *menuimg = [UIImage imageWithData:menuimageData];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       self.imageView.image = img;
                       //self.imageView.contentMode = UIViewContentModeCenter;
                       
                       self.logoImage.image = logoimg;
                       self.logoImage.contentMode = UIViewContentModeCenter;
                       if ((self.logoImage.bounds.size.width > (logoimg.size.width && self.logoImage.bounds.size.height > logoimg.size.height)))
                       {
                           self.logoImage.contentMode = UIViewContentModeScaleAspectFill;
                       }
                       [self.menuBtn setBackgroundImage:menuimg forState:UIControlStateNormal];
                       
                       UIEdgeInsets insets = UIEdgeInsetsMake(50,25, 50,25);
                       UIImage *stretchableImage = [menuimg resizableImageWithCapInsets:insets];
                       [self.messageBtn  setBackgroundImage:stretchableImage forState:UIControlStateNormal];
                       [self.adminBtn setBackgroundImage:stretchableImage forState:UIControlStateNormal];
                   });
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
            [RCPracticeHelper SharedHelper].isChangePractice =YES;
            [RCPracticeHelper SharedHelper].isLogout =NO;
            [RCPracticeHelper SharedHelper].isApplicationMode =NO;
            [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
            [RCPracticeHelper SharedHelper].isLoginTimeOut = NO;
            [self LogoutTheUser];
            break;
            
          case 2:
            [self performSegueWithIdentifier:@"Terms" sender:self];
            break;
            
//         case 3:
//            [self performSegueWithIdentifier:@"AboutUs" sender:self];
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

-(void)assignMessageCountValue
{
    NSString *countValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"MessageCount"];
    NSLog(@"%@",countValue);
    if ([countValue isEqualToString:@"0"])
    {
        self.messageCountLabel.hidden = YES;
    }
    else
    {
        self.messageCountLabel.hidden = NO;
        self.messageCountLabel.text = [NSString stringWithFormat:@"%ld",(long)[countValue integerValue]];
    }
    [self ChangeBadgeCount];
}


-(void)ChangeBadgeCount
{
    NSString *countValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"MessageCount"];
    NSLog(@"%@",countValue);

    [UIApplication sharedApplication].applicationIconBadgeNumber = [countValue integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:[countValue integerValue] forKey:@"BadgeCount"];;
}

-(void)LogoutTheUser
{
    
    if ([RCPracticeHelper SharedHelper].isLogout || [RCPracticeHelper SharedHelper].isPinFailureAttempt)
    {
        [self hasStartedDownloading:@"Logging Out..."];
    }
    [RCSessionEngine SharedWebEngine].delegate = self;
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


-(void)clearData
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)sendRequest:(NSString *)searchPraticeString
{
    [FileDownloader SharedInstance].delegate = self;
    [[FileDownloader SharedInstance] downloadFileAndParseFrom:searchPraticeString];
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


-(void)successfullyParsedFiles:(NSMutableArray *)practiceInfo modelData:(Practice *)practice
{
    [statusHUD hide:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AboutUs"])
    {
        AboutUsViewController *aboutController = [segue destinationViewController];
        aboutController.self.Text = @"About";
    }
    if ([segue.identifier isEqualToString:@"Terms"])
    {
        AboutUsViewController *termsController = [segue destinationViewController];
        termsController.self.Text = @"Legal";
    }
}

#pragma connectin Manager Delegate
-(void)connectionManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    if ([[pResultDict objectForKey:@"successfull"]integerValue])
    {
        self.messageHelper = [RCHelper SharedHelper];
        self.messageHelper.messageCount = [pResultDict objectForKey:@"count"];
        NSString * messageCount = [NSString stringWithFormat:@"%@",[pResultDict objectForKey:@"count"]];
        NSLog(@"Damm %@",messageCount);
        
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        [defaults setObject:messageCount forKey:@"MessageCount"];
        [defaults synchronize];
        
        [self assignMessageCountValue];
    }
    else
    {
        [RCPracticeHelper SharedHelper].isChangePractice =NO;
        [RCPracticeHelper SharedHelper].isLogout =NO;
        [RCPracticeHelper SharedHelper].isApplicationMode = NO;
        [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
        [RCPracticeHelper SharedHelper].isLoginTimeOut = YES;
        
        if (_loginSessionAlert)
        {
            [_loginSessionAlert dismissWithClickedButtonIndex:0 animated:NO];

        }
        _loginSessionAlert = [[UIAlertView alloc]initWithTitle:@"Your session has expired" message:@"You will need to login again. Please press OK to proceed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_loginSessionAlert show];
        [self LogoutTheUser];
        
    }
}

-(void)connectionManagerDidFailWithError:(NSError *)error
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopActivity)];
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
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
            [[RCHelper SharedHelper] setUserWithUserName:[userDict valueForKey:kUserName] andPin:nil andLoggedIN:NO];
            [self performSegueWithIdentifier:@"MoveBackToSelectPractice" sender:self];
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
