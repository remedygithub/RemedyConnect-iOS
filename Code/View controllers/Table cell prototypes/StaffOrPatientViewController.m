//
//  StaffOrPatientViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 31/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "StaffOrPatientViewController.h"
#import "Skin.h"
//#import "SearchPracticeViewController.h"
@interface StaffOrPatientViewController ()

@end

@implementation StaffOrPatientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    practiceName = [[NSUserDefaults standardUserDefaults]objectForKey:@"nameOfPratice"];
    NSLog(@"%@",practiceName);
    self.village = [[UIImageView alloc]init];
    [self.view addSubview:self.village];
    [Skin applyMainMenuBGOnImageView:_imageView];
    [Skin applyMainLogoOnImageView:_logoImage];
    [self displayImages];
    [self checkForUserLastInteractedPage];
   
}


-(void)checkForUserLastInteractedPage
{
    if ([self checkForfiles])
    {
        // checks if user is already moved into some other views
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kPath])
        {
            return;
        }
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kPath] isEqualToString:kPatient])
        {
            [self performSegueWithIdentifier:@"ToPatient" sender:self];
        }
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kPath] isEqualToString:kProvider])
        {
            [self performSegueWithIdentifier:@"ToProvider" sender:self];
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
    //[self setFrames];
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
                       if ([practiceName isEqualToString:@"Village Pediatrics (Westport, CT)"] || [practiceName isEqualToString:@"Union Pediatrics, PSC"] ||[practiceName isEqualToString:@"Children's Healthcare Center"] || [practiceName isEqualToString:@"Brighton Pediatrics"] || [practiceName isEqualToString:@"Goodtime Pediatrics"])
                       {
                           self.village.image = logoimg;
                       }
                       else
                       {
                           self.logoImage.image = logoimg;
                       }
                       [self.patientBtn  setBackgroundImage:btnImag forState:UIControlStateNormal];
                       [self.providerBtn setBackgroundImage:btnImag forState:UIControlStateNormal];
                   });
}


- (IBAction)backBtnTapped:(id)sender
{
    [RCHelper SharedHelper].fromSelfSelectBack = YES;
    [RCHelper SharedHelper].fromSelfSelect = NO;
    [RCHelper SharedHelper].fromMenuReturn = NO;
}

- (IBAction)patientBtnTapped:(id)sender
{
    NSUserDefaults *patientDefaults = [NSUserDefaults standardUserDefaults];
    [patientDefaults setObject:kPatient forKey:kPath];
    [patientDefaults synchronize];
    [self performSegueWithIdentifier:@"ToPatient" sender:self];

}

- (IBAction)providerBtnTapped:(id)sender
{
    //Login
    NSUserDefaults *patientDefaults = [NSUserDefaults standardUserDefaults];
    [patientDefaults setObject:kProvider forKey:kPath];
    [patientDefaults synchronize];
    [self performSegueWithIdentifier:@"ToProvider" sender:self];
}

- (IBAction)returnToSearchBtnTapped:(id)sender
{
    [RCHelper SharedHelper].fromSelfSelect = YES;
    [RCHelper SharedHelper].fromSelfSelectBack = NO;
    [RCHelper SharedHelper].fromMenuReturn = NO;
}

//Checking for device Orientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
        //[self setFrames];
    }
    else
    {
        NSLog(@"Portrait");
       // [self setFrames];
        
    }
}

//#pragma mark Orientation handling
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
//}
//
//-(BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
//}



//#pragma Setting Frames
//-(void)setFrames
//{
//    
//    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
//    {
//        if (IS_IPHONE_6H)
//        {
//            self.amLabel.frame = CGRectMake(100,200,70, 20);
//            self.patientBtn.frame = CGRectMake(100,230,440, 50);
//            self.providerBtn.frame = CGRectMake(100,290,440, 50);
//            self.returnSearchLabel.frame = CGRectMake(250,340,132,30);
//        }
//        else if (IS_IPHONE_5H)
//        {
//            self.amLabel.frame = CGRectMake(60,160,70, 20);
//            self.patientBtn.frame = CGRectMake(60,185,400, 50);
//            self.providerBtn.frame = CGRectMake(60,240,400, 50);
//            self.returnSearchLabel.frame = CGRectMake(190,290,132,30);
//        }
//    }
//    else
//    {
//        if (IS_IPHONE_6)
//        {
//            self.backBtn.frame = CGRectMake(12,50,40,40);
//            self.logoImage.frame = CGRectMake(120,90,240,70);
//            self.amLabel.frame = CGRectMake(50,440,70,20);
//            self.patientBtn.frame = CGRectMake(50,470,280,50);
//            self.providerBtn.frame = CGRectMake(50,530,280,50);
//            self.returnSearchLabel.frame = CGRectMake(120,588,132,30);
//        }
//        else if (IS_IPHONE_5)
//        {
//            self.backBtn.frame = CGRectMake(12,40,40,40);
//            if ([practiceName isEqualToString:@"Village Pediatrics (Westport, CT)"])
//            {
//                self.village.frame = CGRectMake(30,30,260,170);                
//            }
//            else if([practiceName isEqualToString:@"Union Pediatrics, PSC"])
//            {
//                self.village.frame = CGRectMake(67,65,180,100);
//            }
//            else if([practiceName isEqualToString:@"Children's Healthcare Center"])
//            {
//                self.village.frame = CGRectMake(10,-10,298,250);
//            }
//            else if([practiceName isEqualToString:@"Brighton Pediatrics"])
//            {
//                self.village.frame = CGRectMake(10,10,300,200);
//            }
//            else if ([practiceName isEqualToString:@"Goodtime Pediatrics"])
//            {
//                self.village.frame = CGRectMake(20,10,280,220);
//            }
//            else
//            {
//                self.logoImage.frame = CGRectMake(110,90,200,70);
//            }
//            self.amLabel.frame = CGRectMake(20,340,70, 20);
//            self.patientBtn.frame = CGRectMake(20,372,280, 50);
//            self.providerBtn.layer.cornerRadius = 20.0f;
//            self.providerBtn.clipsToBounds = YES;
//            self.providerBtn.frame = CGRectMake(20,430,280, 50);
//            self.returnSearchLabel.frame = CGRectMake(100,488,132, 30);
//        }
//        else if (IS_IPHONE_4)
//        {
//            self.backBtn.frame = CGRectMake(12,30,40,40);
//            if ([practiceName isEqualToString:@"Village Pediatrics (Westport, CT)"])
//            {
//                self.village.frame = CGRectMake(30,30,260,170);
//            }
//            else if([practiceName isEqualToString:@"Union Pediatrics, PSC"])
//            {
//                self.village.frame = CGRectMake(67,65,180,100);
//            }
//            else if([practiceName isEqualToString:@"Children's Healthcare Center"])
//            {
//                self.village.frame = CGRectMake(50,30,298,274);
//            }
//            else if([practiceName isEqualToString:@"Brighton Pediatrics"])
//            {
//                self.village.frame = CGRectMake(10,10,300,200);
//            }
//            else if ([practiceName isEqualToString:@"Goodtime Pediatrics"])
//            {
//                self.village.frame = CGRectMake(20,10,280,220);
//            }
//            else
//            {
//                self.logoImage.frame = CGRectMake(120,80,200,70);
//            }
//            self.amLabel.frame = CGRectMake(40,250,70, 20);
//            self.patientBtn.frame = CGRectMake(20,100,280,50);
//            self.providerBtn.frame = CGRectMake(20,340,280,50);
//            self.returnSearchLabel.frame = CGRectMake(90,400,132,30);
//        }
//    }
//}


@end
