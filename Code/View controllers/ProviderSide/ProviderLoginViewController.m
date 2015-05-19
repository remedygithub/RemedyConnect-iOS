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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    [self setThePaddingForTextFields];
    self.userNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    [self registerForKeyboardNotifications];
    [self checkViewOrientation];


    if ([RCHelper SharedHelper].fromLoginTimeout)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter your RemedyOnCall Admin Username and Password below. Your log in will last 6 HOURS." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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

- (IBAction)backBtnTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPath];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forgotBtnTapped:(id)sender
{
    [self performSegueWithIdentifier:@"MoveToForgotView" sender:self];
}

- (IBAction)loginBtnTapped:(id)sender
{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    if ([NetworkViewController SharedWebEngine].NetworkConnectionCheck)
    {
        if (![self.userNameTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] )
        {
               NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
               [defaults setObject:self.userNameTextField.text forKey:@"user"];
               [defaults setObject:self.passwordTextField.text forKey:@"password"];
               [defaults synchronize];
                
                [RCWebEngine SharedWebEngine].delegate = self;
                [[UIApplication sharedApplication].delegate performSelector:@selector(startActivity)];
                [[RCWebEngine SharedWebEngine]userLogin:self.userNameTextField.text password:self.passwordTextField.text];
        }
        else
        {
            if ([self.userNameTextField.text isEqualToString:@""] && [self.passwordTextField.text isEqualToString:@""])
            {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Please enter UserName and Password" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            else if ([self.userNameTextField.text isEqualToString:@""])
            {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Please enter UserName" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else if ([self.passwordTextField.text isEqualToString:@""])
            {
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"Please enter Password" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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


- (void)hasStartedDownloading
{
    if (nil != statusHUD)
    {
        [statusHUD hide:TRUE];
    }
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD show:YES];
    [statusHUD setLabelText:@"Logging In..."];
    [self.view bringSubviewToFront:statusHUD];
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
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopActivity)];
    if ([pResultDict objectForKey:@"token"] != [NSNull null] )
    {
        helper = [[RCHelper alloc]init];
        helper.PhysicianID = [pResultDict objectForKey:@"physicianID"];
        helper.practiceID = [pResultDict objectForKey:@"practiceID"];
        helper.tokenID = [pResultDict objectForKey:@"token"];
        
          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         [defaults setObject:helper.tokenID forKey:@"responseToken"];
         [defaults synchronize];
        
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
    else
    {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Sorry! Your login failed. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlert show];
    }

}

-(void)connectionManagerDidFailWithError:(NSError *)error
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopActivity)];
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MoveToCreatePin"])
    {
        CreatePINViewController *detailAboutSpeaker = (CreatePINViewController*)segue.destinationViewController;
        detailAboutSpeaker.self.registerHelper = helper;
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


@end
