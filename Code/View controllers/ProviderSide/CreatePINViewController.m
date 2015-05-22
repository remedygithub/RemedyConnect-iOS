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
    [self setFrames];
  
    NSString *practieID = self.registerHelper.practiceID;
    NSString *physicanID = self.registerHelper.PhysicianID;
 
    NSString *userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"user"];
    NSLog(@"%@",userName);
    //Encrypting the Username into Hash value (Message-Digest MD5)
    NSString *hashUserString = [userName MD5];
    NSLog(@"%@",hashUserString);
    
    [RCWebEngine SharedWebEngine].delegate = self;
    [[UIApplication sharedApplication].delegate performSelector:@selector(startActivity)];
    [[RCWebEngine SharedWebEngine] sendRequestForRegister:practieID Physician:physicanID device:hashUserString];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self setFrames];
    
}


- (IBAction)backBtnTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

//Checking for device Orientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
        [self setFrames];
    }
    else
    {
        NSLog(@"Portrait");
        [self setFrames];
        
    }
}



#pragma mark Orientation handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}

#pragma Setting Frames
-(void)setFrames
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        if (IS_IPHONE_6H)
        {
            self.backBtn.frame = CGRectMake(6,25,40,40);
            self.logoView.frame = CGRectMake(0,70,670,70);
            self.logoImage.frame = CGRectMake(180,8,285,54);
            self.label1.frame = CGRectMake(40,150,600,40);
            self.label2.frame = CGRectMake(40,180,600,70);
            self.label2.numberOfLines = 2;
            self.createPin.frame = CGRectMake(180,260,300, 50);
        }
        else if (IS_IPHONE_5H)
        {
            self.backBtn.frame = CGRectMake(6,10,40,40);
            self.logoView.frame = CGRectMake(0,50,580,50);
            self.logoImage.frame = CGRectMake(130,5,270,40);
            self.label1.frame = CGRectMake(10,100,480,50);
            self.label1.numberOfLines = 2;
            self.label2.frame = CGRectMake(10,145,560,50);
            self.label2.numberOfLines = 4;
            self.createPin.frame = CGRectMake(110,230,280,50);
        }
    }
    else
    {
        if (IS_IPHONE_6)
        {
            self.backBtn.frame = CGRectMake(6, 55, 40, 40);
            self.logoView.frame = CGRectMake(0, 110, 400, 70);
            self.logoImage.frame = CGRectMake(45,8,285, 54);
            self.label1.frame = CGRectMake(30,180,380,70);
            self.label1.numberOfLines = 2;
            self.label2.frame = CGRectMake(30,240,360,70);
            self.label2.numberOfLines = 3;
            self.createPin.frame = CGRectMake(50,380,276,50);
        }
        else if (IS_IPHONE_5)
        {
            self.backBtn.frame = CGRectMake(6,45,40,40);
            self.logoView.frame = CGRectMake(0,95,320, 70);
            self.logoImage.frame = CGRectMake(15,8, 285, 54);
            self.label1.frame = CGRectMake(15,170,330,70);
            self.label1.numberOfLines = 2;
            self.label2.frame = CGRectMake(15,240,300,70);
            self.label2.numberOfLines = 3;
            self.createPin.frame = CGRectMake(30,360,250,50);
        }
        else if (IS_IPHONE_4)
        {
            self.backBtn.frame = CGRectMake(6,20,40,40);
            self.logoView.frame = CGRectMake(0,65,320,60);
            self.logoImage.frame = CGRectMake(15,6,285,50);
            self.label1.frame = CGRectMake(15,130,330,70);
            self.label1.numberOfLines = 3;
            self.label2.frame = CGRectMake(15,190,300,70);
            self.label2.numberOfLines = 3;
            self.createPin.frame = CGRectMake(40,290,250,50);
        }
    }
    self.createPin.layer.borderWidth = 1.0f;
    self.createPin.layer.borderColor = ButtonborderColor;
}


@end
