//
//  MessageDetailsViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 23/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "MessageDetailsViewController.h"
@interface MessageDetailsViewController ()

@end

@implementation MessageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.scrollView.backgroundColor = [UIColor whiteColor];
    logic = [Logic sharedLogic];

    self.messageDetails.text = self.messageDetailHelper.messageDetails;
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.phoneLabel.attributedText = [[NSAttributedString alloc] initWithString:self.messageDetailHelper.phoneNumber attributes:underlineAttribute];
    
    [self displayImages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)backBtnTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
            
            //        case 1:
            //            [RCPracticeHelper SharedHelper].isChangePractice =YES;
            //            [RCPracticeHelper SharedHelper].isLogout =NO;
            //            [RCPracticeHelper SharedHelper].isApplicationMode =NO;
            //            [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
            //            [RCPracticeHelper SharedHelper].isLoginTimeOut = NO;
            //
            //            [self LogoutTheUser];
            //            break;
            //
        case 2:
            [self performSegueWithIdentifier:@"MoveFromMsgDetailToTerms" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"MoveFromMsgDetailToAbout" sender:self];
            break;
            //
            //        case 4:
            //            [RCPracticeHelper SharedHelper].isChangePractice =NO;
            //            [RCPracticeHelper SharedHelper].isLogout =YES;
            //            [RCPracticeHelper SharedHelper].isApplicationMode =NO;
            //            [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
            //            [RCPracticeHelper SharedHelper].isLoginTimeOut = NO;
            //            [self LogoutTheUser];
            //            break;
            //
            //        case 5:
            //            [RCPracticeHelper SharedHelper].isChangePractice =NO;
            //            [RCPracticeHelper SharedHelper].isLogout =NO;
            //            [RCPracticeHelper SharedHelper].isApplicationMode = YES;
            //            [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
            //            [RCPracticeHelper SharedHelper].isLoginTimeOut = NO;
            //            [self LogoutTheUser];
            //            break;
            
        default:
            break;
            
    }
    [popoverView dismiss:TRUE];
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MoveFromMsgDetailToTerms"])
    {
        AboutUsViewController *aboutController = [segue destinationViewController];
        aboutController.self.Text = @"Terms and Conditions";
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
   
    NSString *logoimageFilePath = [unzipPath stringByAppendingPathComponent:@"menulogo.png"];
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


@end
