//
//  ProviderLoginViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 06/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "ProviderLoginViewController.h"
#import "NSString+MD5.h"
#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>
#define kOFFSET_FOR_KEYBOARD 80.0

@interface ProviderLoginViewController ()

@end

@implementation ProviderLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    
    [self setThePaddingForTextFields];
    
    self.userNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.forgotUrl = [[NSURL alloc]init];
    
    self.whiteBackground.layer.cornerRadius = 10.0f;
    
    [self registerForKeyboardNotifications];
    [self checkViewOrientation];
    logic = [Logic sharedLogic];
    [self.backBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:kPath];
    if ([path isEqualToString:kProvider])
    {
        CreatePINViewController *providerLogin = [self.storyboard   instantiateViewControllerWithIdentifier:@"CreatePINViewController"];
        [self.navigationController pushViewController:providerLogin animated:NO];
        return;
    }
    
    NSUserDefaults *patientDefaults = [NSUserDefaults standardUserDefaults];
    [patientDefaults setObject:kProvider forKey:kPath];
    [patientDefaults synchronize];
    

    if ([RCHelper SharedHelper].fromLoginTimeout)
    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter your RemedyOnCall Admin Username and Password below. Your log in will last 6 HOURS." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
    }
    
   }


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [statusHUD hide:YES afterDelay:2];

    [self.navigationController setNavigationBarHidden:YES];
    self.userNameTextField.text = @"";
    self.passwordTextField.text = @"";
    [self checkViewOrientation];
   
}

-(void)checkViewOrientation
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
        self.scrollView.contentSize = CGSizeMake(0,[UIScreen mainScreen].bounds.size.height+160);
    }
    else
    {
        NSLog(@"Portrait");
        self.scrollView.contentSize = CGSizeMake(0,[UIScreen mainScreen].bounds.size.height-10);
        
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    activeField = nil;
    self.scrollView = nil;
    [self unregisterForKeyboardNotifications];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//Back Button Action
- (IBAction)backBtnTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPath];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}





- (IBAction)forgotBtnTapped:(id)sender
{
   self.userNameStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSLog(@"%@",self.userNameStr);
    if (self.userNameStr == nil)
    {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Username cannot be blank" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        self.forgotUrl = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://webteleservicestest.remedyconnect.com/Mobile/Providers/Default.aspx?username=%@",self.userNameStr]];
        NSLog(@"%@",self.forgotUrl);
        [[UIApplication sharedApplication]openURL:self.forgotUrl];
    }
   
}

- (IBAction)loginBtnTapped:(id)sender
{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];

    if ([NetworkViewController SharedWebEngine].NetworkConnectionCheck)
    {
        if (![self.userNameTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] )
        {
            [self changeViewBorderColorBlack];
            if (![self.userNameTextField.text isEqualToString:@""])
            {
                self.userNameTextField.layer.borderWidth = 1.0f;
                self.userNameTextField.layer.borderColor = [UIColor blackColor].CGColor;
            }
            else if (![self.passwordTextField.text isEqualToString:@""])
            {
                self.passwordTextField.layer.borderWidth = 1.0f;
                self.passwordTextField.layer.borderColor = [UIColor blackColor].CGColor;
            }
            
               NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
               [defaults setObject:self.userNameTextField.text forKey:@"user"];
               [defaults setObject:self.passwordTextField.text forKey:@"password"];
               [defaults synchronize];
                
                [RCWebEngine SharedWebEngine].delegate = self;
                [self hasStartedDownloading:@"Logging In..."];
                [[RCWebEngine SharedWebEngine]userLogin:self.userNameTextField.text password:self.passwordTextField.text];
        }
        else
        {
            [self changeViewBorderColorBlack];
            if ([self.userNameTextField.text isEqualToString:@""] && [self.passwordTextField.text isEqualToString:@""])
            {
                [self changeView1BorderColor];
                [self changeView2BorderColor];
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Username and Password cannot be blank" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            else if ([self.userNameTextField.text isEqualToString:@""])
            {
                [self changeView1BorderColor];
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Username cannot be blank" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else if ([self.passwordTextField.text isEqualToString:@""])
            {
                [self changeView2BorderColor];
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Password cannot be blank" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }

    }
}


-(void)sendRequest
{
    NSLog(@"user:%@,pass:%@",self.userNameTextField.text,self.passwordTextField.text);
    [[RCWebEngine SharedWebEngine]userLogin:self.userNameTextField.text password:self.passwordTextField.text];
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

//MenuBtn Action
- (IBAction)menuBtnTapped:(id)sender
{
    CGPoint point = CGPointMake(self.menuBtn.frame.origin.x + self.menuBtn.frame.size.width / 2,
                                self.menuBtn.frame.origin.y + self.menuBtn.frame.size.height);
    [PopoverView showPopoverAtPoint:point
                             inView:self.view
                    withStringArray:[NSArray arrayWithObjects:@"Update Your Practice Info",
                                     @"Choose Your Practice", @"Terms and Conditions",@"About Us",nil]
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
            [RCHelper SharedHelper].isLogin = NO;
            [self performSegueWithIdentifier:@"FromLoginToSelect" sender:self];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"LoginToTerms" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"LoginToAboutUs" sender:self];
            break;
            
            default:
            break;
    }
    [popoverView dismiss:TRUE];
}



-(void)verifyingThePincodeTocheck
{
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
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

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^()
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Pin entered correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        //Move to Message
        [self performSegueWithIdentifier:@"fromLoginToMessage" sender:self];
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

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^()
     {
         NSLog(@"%@",controller.passcode);
         [RCHelper SharedHelper].pinCreated = YES;
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         [defaults setObject:controller.passcode forKey:@"screatKey"];
         [defaults synchronize];
     }];
}


#pragma TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[self animateKeyboardUp];
       activeField = textField;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //[textField resignFirstResponder];
    //[self animateKeyboardDown];
      activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField ==  self.userNameTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }

    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}


- (void)tapDetected:(UITapGestureRecognizer *)tapRecognizer
{
    [activeField resignFirstResponder];
    [self.scrollView removeGestureRecognizer:tapRecognizer];
}


#pragma mark - event of keyboard relative methods
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}



- (void)keyboardWillShown:(NSNotification*)sender
{
    NSDictionary* info = [sender userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect frame = self.view.frame;
    
      if (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation))
        {
            frame.size.height -= kbSize.height + 60;
        }
        else
        {
            frame.size.height -= kbSize.height+60;
        }
    
    CGPoint fOrigin = activeField.frame.origin;
    fOrigin.y -= self.scrollView.contentOffset.y;
    fOrigin.y += activeField.frame.size.height;
    if (!CGRectContainsPoint(frame, fOrigin) )
    {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y + activeField.frame.size.height - frame.size.height);
       // [self.scrollView setContentOffset:scrollPoint animated:YES];
        NSString *scrollPointString = [NSString stringWithFormat:@"%f", scrollPoint.y];
        [self performSelector:@selector(scrollTheView:) withObject:scrollPointString afterDelay:0.05];
    }
}

-(void)scrollTheView:(NSString *) scrollPoint
{
    CGPoint point = CGPointMake(0, [scrollPoint floatValue]);
    [self.scrollView setContentOffset:point animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}


#pragma mark - Delegate methods of RCWebEngine
-(void)connectionManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    [statusHUD hide:YES afterDelay:2];
    if ([pResultDict objectForKey:@"token"] != [NSNull null] )
    {
        helper = [[RCHelper alloc]init];
        helper.PhysicianID = [pResultDict objectForKey:@"physicianID"];
        helper.practiceID = [pResultDict objectForKey:@"practiceID"];
        helper.tokenID = [pResultDict objectForKey:@"token"];

        //Saving Token Locally
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:helper.practiceID forKey:@"userPracticeId"];
         [defaults setObject:helper.tokenID forKey:@"responseToken"];
         [defaults synchronize];
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        dateFormatter.dateFormat = @"HH:mm:ss";
        
        NSString *currentTime = [dateFormatter stringFromDate:today];
        NSLog(@"%@",currentTime);
        NSLog(@"current time:%@",currentTime);
        
         NSUserDefaults *timeDefaults = [NSUserDefaults standardUserDefaults];
        [timeDefaults setObject:currentTime forKey:@"startTime"];
        [timeDefaults synchronize];
        
         [RCHelper SharedHelper].isLogin = YES;
         [self performSegueWithIdentifier:@"MoveToCreatePin" sender:self];

          // if ([RCHelper SharedHelper].pinCreated)
//            {
//                [self performSegueWithIdentifier:@"MoveToProvider" sender:self];
//            }
//            else if ([RCHelper SharedHelper].fromLoginTimeout)
//            {
//                [self verifyingThePincodeTocheck];
  
//            }
//            else
//            {
//                [self performSegueWithIdentifier:@"MoveToCreatePin" sender:self];
//            }
    }
    else
    {
        [self connectionFailed];
    }

}

-(void)connectionFailed
{
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Couldn't log you in" message:@"Unknown username or bad password - please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}

-(void)connectionManagerDidFailWithError:(NSError *)error
{
    [statusHUD hide:YES afterDelay:2];
     UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Couldn't log you in" message:@"Unknown username or bad password - please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MoveToCreatePin"])
    {
        CreatePINViewController *detailAboutSpeaker = (CreatePINViewController*)segue.destinationViewController;
        detailAboutSpeaker.self.registerHelper = helper;
    }
    
    if ([segue.identifier isEqualToString:@"LoginToTerms"])
    {
        AboutUsViewController *termsController = [segue destinationViewController];
        termsController.self.Text = @"Terms and Conditions";
    }
    if ([segue.identifier isEqualToString:@"LoginToAboutUs"])
    {
        AboutUsViewController *aboutController = [segue destinationViewController];
        aboutController.self.Text = @"About";
    }
}


-(void)registerFinishedLoading:(NSDictionary *)pResultDict
{
    
    if ([RCHelper SharedHelper].pinCreated)
    {
        [self performSegueWithIdentifier:@"MoveToProvider" sender:self];
    }
    else if ([RCHelper SharedHelper].fromLoginTimeout)
    {
        [self verifyingThePincodeTocheck];
    }
    else
    {
        [self performSegueWithIdentifier:@"MoveToCreatePin" sender:self];
    }
}

-(void)registerFailedLoading:(NSError *)error
{
    NSLog(@"Error info: %@", [error description]);
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopActivity)];
    
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}



#pragma mark-KeyboardAnimateMovement
-(void)animateKeyboardUp
{
    if (IS_IPHONE_6H)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,(self.scrollView.frame.origin.y - 100.0),self.scrollView.frame.size.width,self.scrollView.frame.size.height);
        [UIView commitAnimations];
    }
    else if (IS_IPHONE_5)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.scrollView.frame = CGRectMake( self.scrollView.frame.origin.x, (self.scrollView.frame.origin.y -80.0),self.scrollView.frame.size.width,self.scrollView.frame.size.height);
        [UIView commitAnimations];
    }
    else if (IS_IPHONE_4 || IS_IPHONE_5H)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.scrollView.frame = CGRectMake( self.scrollView.frame.origin.x, ( self.scrollView.frame.origin.y - 100.0),  self.scrollView.frame.size.width,  self.scrollView.frame.size.height);
        [UIView commitAnimations];
    }
}

-(void)animateKeyboardDown
{
    if (IS_IPHONE_6H)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, (self.scrollView.frame.origin.y + 100.0), self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [UIView commitAnimations];
    }
    else if (IS_IPHONE_5)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.scrollView.frame = CGRectMake( self.scrollView.frame.origin.x, ( self.scrollView.frame.origin.y +10.0),  self.scrollView.frame.size.width,  self.scrollView.frame.size.height);
        [UIView commitAnimations];
    }
    else if (IS_IPHONE_4 || IS_IPHONE_5H)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.scrollView.frame = CGRectMake( self.scrollView.frame.origin.x, ( self.scrollView.frame.origin.y +100.0),  self.scrollView.frame.size.width,  self.scrollView.frame.size.height);
        [UIView commitAnimations];
    }
}

//Checking for device Orientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration

{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
        self.scrollView.contentSize = CGSizeMake(0,[UIScreen mainScreen].bounds.size.height+160);

    }
    else
    {
        NSLog(@"Portrait");
        self.scrollView.contentSize = CGSizeMake(0,[UIScreen mainScreen].bounds.size.height-10);
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


-(void)changeViewBorderColorBlack
{
    self.userNameTextField.background = [UIImage imageNamed:@"input.png"];
    self.passwordTextField.background = [UIImage imageNamed:@"input.png"];
}

-(void)changeView1BorderColor
{
    self.userNameTextField.background = [UIImage imageNamed:@"password.png"];
}

-(void)changeView2BorderColor
{
    self.passwordTextField.background = [UIImage imageNamed:@"password.png"];
}

//Padding for textfields
-(void) setThePaddingForTextFields
{
    UIView *firstNPaddig = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    self.userNameTextField.leftView = firstNPaddig;
    self.userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *lastNPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    self.passwordTextField.leftView = lastNPadding;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
}
//http://stackoverflow.com/questions/15092016/how-to-run-nstimer-in-background-and-sleep-in-ios
@end
