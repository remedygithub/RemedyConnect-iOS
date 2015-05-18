//
//  StaffOrPatientViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 31/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "StaffOrPatientViewController.h"
#import "SearchPracticeViewController.h"
@interface StaffOrPatientViewController ()

@end

@implementation StaffOrPatientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setFrames];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    if([RCHelper SharedHelper].fromSelfSelect || [RCHelper SharedHelper].fromMenuReturn || [RCHelper SharedHelper].fromSelfSelectBack)
    {
        [self checkForfiles];
    }
    else
    {
        [self performSelector:@selector(checkForfiles) withObject:nil afterDelay:0.0];
    }
    [self setFrames];

}

-(void)checkForfiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:unzipPath])
    {
        self.patientBtn.hidden = YES;
        self.providerBtn.hidden = YES;
        [RCHelper SharedHelper].fromSelfSelect = NO;
        [self performSegueWithIdentifier:@"toSearch" sender:self];
    }
    else
    {
        if (self.backImage)
        {
            [self.backImage removeFromSuperview];
            self.backImage  = nil;
        }
        self.patientBtn.hidden = NO;
        self.providerBtn.hidden = NO;
        [self displayImages];
    }
}

-(void)displayImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    NSString *imageFilePath = [unzipPath stringByAppendingPathComponent:@"background.png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
    UIImage *img = [UIImage imageWithData:imageData];
    
    NSString *logoimageFilePath = [unzipPath stringByAppendingPathComponent:@"logo.png"];
    NSData *logoimageData = [NSData dataWithContentsOfFile:logoimageFilePath options:0 error:nil];
    UIImage *logoimg = [UIImage imageWithData:logoimageData];
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       self.imageView.image = img;
                       self.logoImage.image = logoimg;
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
}

- (IBAction)providerBtnTapped:(id)sender
{
    //Login
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
        [self setFrames];
    }
    else
    {
        NSLog(@"Portrait");
        [self setFrames];
        
    }
}

#pragma Setting Frames
-(void)setFrames
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        if (IS_IPHONE_6H)
        {
            self.amLabel.frame = CGRectMake(100,200,70, 20);
            self.patientBtn.frame = CGRectMake(100,230,440, 50);
            self.providerBtn.frame = CGRectMake(100,290,440, 50);
            self.returnSearchLabel.frame = CGRectMake(250,340,132,30);
        }
        else if (IS_IPHONE_5H)
        {
            self.amLabel.frame = CGRectMake(60,160,70, 20);
            self.patientBtn.frame = CGRectMake(60,185,400, 50);
            self.providerBtn.frame = CGRectMake(60,240,400, 50);
            self.returnSearchLabel.frame = CGRectMake(190,290,132,30);
        }
    }
    else
    {
        if (IS_IPHONE_6)
        {
            self.backBtn.frame = CGRectMake(12,50,40,40);
            self.logoImage.frame = CGRectMake(120,90, 240, 70);
            self.amLabel.frame = CGRectMake(50,440,70, 20);
            self.patientBtn.frame = CGRectMake(50,470, 280, 50);
            self.providerBtn.frame = CGRectMake(50, 530, 280, 50);
            self.returnSearchLabel.frame = CGRectMake(120,588,132, 30);
        }
        else if (IS_IPHONE_5)
        {
            self.backBtn.frame = CGRectMake(12,40,40,40);
            self.logoImage.frame = CGRectMake(110,90,200,70);
            self.amLabel.frame = CGRectMake(20,340,70, 20);
            self.patientBtn.frame = CGRectMake(20,372,280, 50);
            self.providerBtn.frame = CGRectMake(20,430,280, 50);
            self.returnSearchLabel.frame = CGRectMake(100,488,132, 30);
        }
        else if (IS_IPHONE_4)
        {
            self.backBtn.frame = CGRectMake(12,30,40,40);
            self.logoImage.frame = CGRectMake(120,80,200,70);
            self.amLabel.frame = CGRectMake(40,310,70, 20);
            self.patientBtn.frame = CGRectMake(20,340,280,50);
            self.providerBtn.frame = CGRectMake(20,400,280,50);
            self.returnSearchLabel.frame = CGRectMake(90,450,132,30);
        }
    }
    self.patientBtn.layer.borderWidth = 1.0f;
    self.patientBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.providerBtn.layer.borderWidth = 1.0f;
    self.providerBtn.layer.borderColor = [UIColor whiteColor].CGColor;
}


@end
