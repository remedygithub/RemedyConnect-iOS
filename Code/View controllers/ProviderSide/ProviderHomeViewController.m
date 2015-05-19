//
//  ProviderHomeViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 08/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "ProviderHomeViewController.h"

@interface ProviderHomeViewController ()

@end

@implementation ProviderHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    practiceName = [[NSUserDefaults standardUserDefaults]objectForKey:@"nameOfPratice"];
    self.village = [[UIImageView alloc]init];
    [self.view addSubview:self.village];
    logic = [Logic sharedLogic];
    [self displayImages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                       self.imageView.contentMode = UIViewContentModeCenter;
                       self.logoImage.image = logoimg;
                       self.logoImage.contentMode = UIViewContentModeCenter;
                       if ((self.logoImage.bounds.size.width > (logoimg.size.width && self.logoImage.bounds.size.height > logoimg.size.height)))
                       {
                           self.logoImage.contentMode = UIViewContentModeScaleAspectFill;
                       }
                       [self.menuBtn setBackgroundImage:menuimg forState:UIControlStateNormal];
                       [self.messageBtn setBackgroundImage:menuimg forState:UIControlStateNormal];
                       [self.adminBtn setBackgroundImage:menuimg forState:UIControlStateNormal];
                   });
}



- (IBAction)menuBtnTapped:(id)sender
{
    CGPoint point = CGPointMake(self.menuBtn.frame.origin.x + self.menuBtn.frame.size.width / 2,
                                self.menuBtn.frame.origin.y + self.menuBtn.frame.size.height);
    [PopoverView showPopoverAtPoint:point
                             inView:self.view
                    withStringArray:[NSArray arrayWithObjects:@"Update Your Practice Info",
                                     @"Patient/Guardian", @"Return to Search",@"About",@"Terms and Conditions", nil]
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
            if ([RCHelper SharedHelper].fromAgainList)
            {
                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
            }
            else
            {
                //[logic setMainMenuDelegate:self];
                [RCHelper SharedHelper].menuToArticle = YES;
                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
            }
            break;
            
        case 2:
            [RCHelper SharedHelper].fromMenuReturn = YES;
            [RCHelper SharedHelper].fromSelfSelect = NO;
            [RCHelper SharedHelper].fromSelfSelectBack = NO;
            [self clearData]; 
            [self performSegueWithIdentifier:@"MoveBackToSelectPractice" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"AboutUs" sender:self];
            break;
            
        case 4:
            [self performSegueWithIdentifier:@"Terms" sender:self];
            break;
    }
    [popoverView dismiss:TRUE];
}

-(void)clearData
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPath];
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
        termsController.self.Text = @"Terms and Conditions";
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}



//Checking for device Orientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
    }
    else
    {
        NSLog(@"Portrait");
        
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

//#pragma Setting Frames
//-(void)setFrames
//{
//    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight))
//    {
//        if (IS_IPHONE_6H)
//        {
//            self.menuBtn.frame = CGRectMake(600, 62, 30, 30);
//            self.logoImage.frame = CGRectMake(420,120,240, 70);
//            self.messageBtn.frame = CGRectMake(190,250,124,60);
//            self.adminBtn.frame = CGRectMake(360,250,124,60);
//        }
//        else if (IS_IPHONE_5H)
//        {
//            self.menuBtn.frame = CGRectMake(420, 62, 30, 30);
//            self.logoImage.frame = CGRectMake(260,100,200, 70);
//            self.messageBtn.frame = CGRectMake(110,230,124,60);
//            self.adminBtn.frame = CGRectMake(280,230,124,60);
//        }
//    }
//    else
//    {
//        if (IS_IPHONE_6)
//        {
//            self.menuBtn.frame = CGRectMake(300, 62, 30, 30);
//            self.logoImage.frame = CGRectMake(120,120,240, 70);
//            self.messageBtn.frame = CGRectMake(120,480,124,60);
//            self.adminBtn.frame = CGRectMake(120,560,124,60);
//        }
//        else if (IS_IPHONE_5)
//        {
//            self.menuBtn.frame = CGRectMake(260,62,30,30);
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
//               self.village.frame = CGRectMake(10,10,300,200);
//            }
//            else if ([practiceName isEqualToString:@"Goodtime Pediatrics"])
//            {
//                self.village.frame = CGRectMake(20,10,280,220);
//            }
//            else if ([practiceName isEqualToString:@"Collin County Pediatrics"])
//            {
//                self.village.frame = CGRectMake(20,60,280,114);
//            }
//            else
//            {
//                self.logoImage.frame = CGRectMake(100,100,200,70);
//            }
//            self.messageBtn.frame = CGRectMake(100,380,124,60);
//            self.adminBtn.frame = CGRectMake(100,460,124,60);
//        }
//        else if (IS_IPHONE_4)
//        {
//            self.menuBtn.frame = CGRectMake(260,62,30,30);
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
//            else if ([practiceName isEqualToString:@"Collin County Pediatrics"])
//            {
//                self.village.frame = CGRectMake(20,60,280,114);
//            }
//            else
//            {
//                self.logoImage.frame = CGRectMake(100,100,200,70);
//
//            }
//            self.messageBtn.frame = CGRectMake(100,340,124,60);
//            self.adminBtn.frame = CGRectMake(100,410,124,60);
//        }
//    }
//    self.messageBtn.layer.cornerRadius = 10.0f;
//    self.adminBtn.layer.cornerRadius = 10.0f;
//}
@end
