//
//  StaffOrPatientViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 31/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "StaffOrPatientViewController.h"
#import "Skin.h"
#import "MainMenuViewController.h"
#import "ProviderLoginViewController.h"
#import "ProviderHomeViewController.h"
#import "CreatePINViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import "SearchPracticeViewController.h"
@interface StaffOrPatientViewController ()
@property(nonatomic, strong) UIViewController *lastLauncedController;
@property (nonatomic, strong)PopoverView *mPopver;

@end

@implementation StaffOrPatientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    practiceName = [[NSUserDefaults standardUserDefaults]objectForKey:@"nameOfPratice"];
    NSLog(@"%@",practiceName);
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.village = [[UIImageView alloc]init];
    [self.view addSubview:self.village];
    [self displayImages];
    [Skin applyMainMenuBGOnImageView:_imageView];
    [Skin applyMainLogoOnImageView:_logoImage];
    [self checkForUserLastInteractedPage];
    [self.view bringSubviewToFront:self.patientBtn];
    [self.view bringSubviewToFront:self.providerBtn];
   
}



-(void)checkForUserLastInteractedPage
{
    if ([self checkForfiles])
    {
        // checks if user is already moved into some other views
        NSString *savedClassName = [[NSUserDefaults standardUserDefaults] objectForKey:KLastLaunchedController];
        if (savedClassName)
        {
           _lastLauncedController  = [self.storyboard   instantiateViewControllerWithIdentifier:savedClassName];
            [self.navigationController pushViewController:_lastLauncedController animated:NO];
        }
   }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    //[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

    if([RCHelper SharedHelper].fromSelfSelect || [RCHelper SharedHelper].fromMenuReturn || [RCHelper SharedHelper].fromSelfSelectBack)
    {
        [self checkForfiles];
    }
    else
    {
        [self performSelector:@selector(checkForfiles) withObject:nil afterDelay:0.0];
    }
    //[self setFrames];
    [self displayImages];
}

-(BOOL)checkForfiles
{
    BOOL isFileExist = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:unzipPath])
    {
        self.patientBtn.hidden = YES;
        self.providerBtn.hidden = YES;
        //[RCHelper SharedHelper].fromSelfSelect = NO;
        [self performSegueWithIdentifier:@"toSearch" sender:self];
    }
    else
    {
        isFileExist = YES;
        if (self.backImage)
        {
            [self.backImage removeFromSuperview];
            self.backImage  = nil;
        }
        self.patientBtn.hidden = NO;
        self.providerBtn.hidden = NO;
        [self displayImages];
    }
    return isFileExist;
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
    
    NSString *btnimageFilePath = [unzipPath stringByAppendingPathComponent:@"button.9.png"];
    NSData *btnimageData = [NSData dataWithContentsOfFile:btnimageFilePath options:0 error:nil];
    UIImage *btnImag = [UIImage imageWithData:btnimageData];
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       self.imageView.image = img;
                        NSLog(@"%f %f",self.imageView.frame.size.width,self.imageView.frame.size.height);
                       self.logoImage.image = logoimg;
                       //self.logoImage.contentMode = UIViewContentModeCenter;
                       if ((self.logoImage.bounds.size.width > (logoimg.size.width && self.logoImage.bounds.size.height > logoimg.size.height)))
                       {
                           self.logoImage.contentMode = UIViewContentModeScaleAspectFit;
                       }
                       [self.backBtn  setBackgroundImage:btnImag forState:UIControlStateNormal];
                       
                       UIEdgeInsets insets = UIEdgeInsetsMake(50,25, 50,25);
                       
                       UIImage *stretchableImage = [btnImag resizableImageWithCapInsets:insets];
                       [self.patientBtn  setBackgroundImage:stretchableImage forState:UIControlStateNormal];
                       [self.providerBtn setBackgroundImage:stretchableImage forState:UIControlStateNormal];
                        [self.menuBtn setBackgroundImage:btnImag forState:UIControlStateNormal];
                       
                   });
}


- (IBAction)backBtnTapped:(id)senderr
{
    [RCHelper SharedHelper].fromSelfSelectBack = YES;
    [RCHelper SharedHelper].fromSelfSelect = NO;
    [RCHelper SharedHelper].fromMenuReturn = NO;
}

- (IBAction)patientBtnTapped:(id)sender
{
//    NSUserDefaults *patientDefaults = [NSUserDefaults standardUserDefaults];
//    [patientDefaults setObject:kPatient forKey:kPath];
//    [patientDefaults synchronize];
    [self performSegueWithIdentifier:@"ToPatient" sender:self];

}

- (IBAction)providerBtnTapped:(id)sender
{
    //Login
    [self performSegueWithIdentifier:@"ToProvider" sender:self];
}

- (IBAction)returnToSearchBtnTapped:(id)sender
{
    [RCHelper SharedHelper].fromSelfSelect = YES;
    [RCHelper SharedHelper].fromSelfSelectBack = NO;
    [RCHelper SharedHelper].fromMenuReturn = NO;
}


- (IBAction)menuBtnTapped:(id)sender
{
    CGPoint point = CGPointMake(self.menuBtn.frame.origin.x + self.menuBtn.frame.size.width / 2,
                                self.menuBtn.frame.origin.y + self.menuBtn.frame.size.height);
//    [PopoverView showPopoverAtPoint:point
//                             inView:self.view
//                    withStringArray:[NSArray arrayWithObjects:
//                                     @"Choose Your Practice", @"Legal",nil]
//                           delegate:self];
    
    if (_mPopver) {
        [_mPopver removeFromSuperview];
        _mPopver = nil;
    }
    _mPopver= [[PopoverView alloc] initWithFrame:CGRectZero];
    [_mPopver showAtPoint:point inView:self.view withStringArray:[NSArray arrayWithObjects:@"Choose Your Practice", @"Legal",nil]];
    _mPopver.delegate = self;
}



- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    NSString * praticeName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nameOfPratice"];
    NSLog(@"%@",praticeName);
    switch (index)
    {
        case 0:
//            [RCHelper SharedHelper].isLogin = NO;
//            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPath];
//            [[NSUserDefaults standardUserDefaults]synchronize];
            [self performSegueWithIdentifier:@"MoveTosearchAgain" sender:self];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"SelfToTerms" sender:self];
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
   
    if ([segue.identifier isEqualToString:@"SelfToTerms"])
    {
        AboutUsViewController *termsController = [segue destinationViewController];
        termsController.self.Text = @"Legal";
    }
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
