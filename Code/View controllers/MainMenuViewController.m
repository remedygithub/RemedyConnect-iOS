//
//  MainMenuViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "MainMenuViewController.h"
#import "Logic.h"
#import "Skin.h"
#import "PopoverView.h"
#import "PracticeSearchViewController.h"
#import "AboutTermsController.h"
#import "MainMenuButtonCell.h"
#import "RCHelper.h"
//#import "TestFlight.h"

@interface MainMenuViewController ()
@property (nonatomic, strong)PopoverView *mPopver;

@end

@implementation MainMenuViewController

Logic *logic;
NSArray *menu;


- (void)viewDidLoad
{
    [super viewDidLoad];

    practiceName = [[NSUserDefaults standardUserDefaults]objectForKey:@"nameOfPratice"];
    self.village = [[UIImageView alloc]init];
    [self.view addSubview:self.village];
    
    [self setMenuHeightInOrientation:[UIApplication sharedApplication].statusBarOrientation beforeRotation:NO];
    logic = [Logic sharedLogic];
    [Skin applyMainMenuBGOnImageView:_backgroundImage];
    [Skin applyMainLogoOnImageView:_logoImageView];
    [Skin applyBackgroundOnButton:_menuButton];
    menu = [logic getDataToDisplayForMainMenu];
    [self setFrames];
    [self displayImages];
    
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([self class]) forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setMenuHeightInOrientation:[UIApplication sharedApplication].statusBarOrientation beforeRotation:NO];
    [super viewWillAppear:animated];
    
    if (![RCHelper SharedHelper].isBackFromArticle)
    {
        [self fetchLatestData];
    }
    [[self navigationController] setNavigationBarHidden:TRUE];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:FALSE animated:TRUE];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:TRUE];
}


-(void)fetchLatestData
{
    if ([NetworkViewController SharedWebEngine].NetworkConnectionCheck)
    {
        [logic setUpdateDownloadStarterDelegate:self];
        [logic handleActionWithTag:0 shouldProceedToPage:FALSE];
    }
}


-(void)displayImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    NSLog(@"%@",unzipPath);
    NSString *imageFilePath = [unzipPath stringByAppendingPathComponent:@"background.png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
    UIImage *img = [UIImage imageWithData:imageData];
    
    NSString *imageFileLogoPath = [unzipPath stringByAppendingPathComponent:@"menulogo.png"];
    NSData *imageLogoData = [NSData dataWithContentsOfFile:imageFileLogoPath options:0 error:nil];
    UIImage *imgLogo = [UIImage imageWithData:imageLogoData];
    
    NSString *menuFilePath = [unzipPath stringByAppendingPathComponent:@"button.9.png"];
    NSData *menuimageData = [NSData dataWithContentsOfFile:menuFilePath options:0 error:nil];
    UIImage *menuimg = [UIImage imageWithData:menuimageData];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       self.backgroundImage.image = img;
                       NSLog(@"%f %f",self.backgroundImage.frame.size.width,self.backgroundImage.frame.size.height);
                       self.logoImageView.image = imgLogo;
//                       if ([practiceName isEqualToString:@"Village Pediatrics (Westport, CT)"]||[practiceName isEqualToString:@"Children's Healthcare Center"] || [practiceName isEqualToString:@"Brighton Pediatrics"] || [practiceName isEqualToString:@"Goodtime Pediatrics"])
//                       {
//                           self.village.image = imgLogo;
//                       }
//                       else
//                       {
//                           self.logoImageView.image = imgLogo;
//                       }
                       [self.backBtn setBackgroundImage:menuimg forState:UIControlStateNormal];
                       [self.menuButton setBackgroundImage:menuimg forState:UIControlStateNormal];
                   });
}

- (void)setMenuHeightInOrientation:(UIInterfaceOrientation)interfaceOrientation
                    beforeRotation:(BOOL)beforeRotation {
    
    CGFloat maxHeight = 360;
    CGFloat minHeight = 150;
    CGFloat screenSizingRatioLandscape = 3.5;
    CGFloat screenSizingRatioPortrait = 2;
    CGFloat height = 0;
    CGFloat screenRatioHeight = 0;
    CGFloat screenSizingRatio = 0;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        screenSizingRatio = screenSizingRatioLandscape;
    }
    else {
        screenSizingRatio = screenSizingRatioPortrait;
    }
    if (beforeRotation) {
        screenRatioHeight = self.view.frame.size.width / screenSizingRatio;
    }
    else {
        screenRatioHeight = self.view.frame.size.height / screenSizingRatio;
    }
    
    height = MAX(minHeight, MIN(screenRatioHeight, maxHeight));
    [self menuHeightConstraint].constant = height;
}

- (IBAction)backBtnTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPath];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if ((UIInterfaceOrientationIsLandscape(currentOrientation) &&
                UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) ||
                (UIInterfaceOrientationIsPortrait(currentOrientation) &&
                 UIInterfaceOrientationIsLandscape(toInterfaceOrientation))) {

        [self setMenuHeightInOrientation:toInterfaceOrientation beforeRotation:YES];
    }
}


#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [menu count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainMenuButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuButtonCell" forIndexPath:indexPath];
    [cell.button setTitle:[[menu objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
    [[cell button] addTarget:self action:@selector(menuClick:event:) forControlEvents:UIControlEventTouchUpInside];
    [Skin applyBackgroundOnButton:cell.button];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    NSString *imageFilePath = [unzipPath stringByAppendingPathComponent:@"button.9.png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
    UIImage *img = [UIImage imageWithData:imageData];
    
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [cell.button setBackgroundImage:img forState:UIControlStateNormal];
                   });
    return cell;
}

- (IBAction)menuClick:(id)sender event:(id)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint currentTouchPos = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentTouchPos];
    if ([RCHelper SharedHelper].menuToArticle)
    {
        [logic setSubMenuDelegate:self];
        [logic handleActionWithTag:indexPath.row shouldProceedToPage:FALSE];
        [self  performSegueWithIdentifier:@"MenuToArticle" sender:self];
    }
    else
    {
        [logic setMainMenuDelegate:self];
        [logic handleActionWithTag:indexPath.row shouldProceedToPage:FALSE];

    }
    //[logic handleActionWithTag:indexPath.row shouldProceedToPage:FALSE];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect wrapperFrame = collectionView.frame;
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        wrapperFrame.size.width /= 3;
        wrapperFrame.size.height /= 2;
    }
    else {
        wrapperFrame.size.width /= 2;
        wrapperFrame.size.height /= 3;
    }
    wrapperFrame.size.width -= 20;
    wrapperFrame.size.height -= 20;
    CGSize retval = wrapperFrame.size;
    return retval;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (IBAction)menuButtonPressed:(id)sender {
    CGPoint point = CGPointMake(_menuButton.frame.origin.x + _menuButton.frame.size.width / 2,
                                _menuButton.frame.origin.y + _menuButton.frame.size.height);
//    [PopoverView showPopoverAtPoint:point
//                             inView:self.view
//                    withStringArray:[NSArray arrayWithObjects:@"Refresh",
//                                     @"Choose Your Practice", @"Legal",@"Provider/Staff",nil]
//                           delegate:self];
    
    if (_mPopver) {
        [_mPopver removeFromSuperview];
        _mPopver = nil;
    }
    _mPopver= [[PopoverView alloc] initWithFrame:CGRectZero];
    [_mPopver showAtPoint:point inView:self.view withStringArray:[NSArray arrayWithObjects:@"Refresh",@"Choose Your Practice", @"Legal",@"Provider/Staff",nil]];
    _mPopver.delegate = self;
}

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            if ([NetworkViewController SharedWebEngine].NetworkConnectionCheck)
            {
                [logic setUpdateDownloadStarterDelegate:self];
                [logic handleActionWithTag:0 shouldProceedToPage:FALSE];
            }
            break;
        case 1:
            [logic resetBeforeSelection];
            [self clearData];
            [[RCHelper SharedHelper] removeAllUsersPinAndLogoff];
            [RCHelper SharedHelper].isBackFromArticle = NO;
            [self performSegueWithIdentifier:@"BackToPracticeSearch" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"toTerms" sender:self];
            break;
//        case 3:
//            [self performSegueWithIdentifier:@"toAbout" sender:self];
//            break;
        case 3:
            //[RCHelper SharedHelper].pinCreated = YES;
            [RCHelper SharedHelper].isBackFromArticle = NO;
            [self.navigationController popToRootViewControllerAnimated:YES];
        
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

-(void)clearData
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toAbout"]) {
        AboutTermsController *aboutController = [segue destinationViewController];
        [aboutController setWebTitle: @"About"];
        [aboutController setWebText: [logic getAboutHTML]];
    }
    if ([segue.identifier isEqualToString:@"toTerms"]) {
        AboutTermsController *termsController = [segue destinationViewController];
        [termsController setWebTitle: @"Legal"];
        [termsController setWebText: [logic getTermsHTML]];
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
    [statusHUD setLabelText:@"Fetching Latest Data..."];
}

- (void)switchToIndeterminate {
    [statusHUD setMode:MBProgressHUDModeIndeterminate];
}

- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status {
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

- (IBAction)resetToHere:(UIStoryboardSegue *)segue {
    [logic unwind];
}

//Checking for device Orientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (_mPopver)
    {
        [self menuButtonPressed:nil];
    }
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
            
        }
        else if (IS_IPHONE_5H)
        {
            self.village.frame = CGRectMake(150,0,260,170);

        }
    }
    else
    {
        if (IS_IPHONE_6)
        {
           
        }
        else if (IS_IPHONE_5)
        {
            if ([practiceName isEqualToString:@"Village Pediatrics (Westport, CT)"])
            {
                self.village.frame = CGRectMake(30,30,260,170);
            }
            else if([practiceName isEqualToString:@"Children's Healthcare Center"])
            {
                self.village.frame = CGRectMake(10,-10,298,250);
            }
            else if([practiceName isEqualToString:@"Brighton Pediatrics"])
            {
                self.village.frame = CGRectMake(10,10,300,200);
            }
            else if ([practiceName isEqualToString:@"Goodtime Pediatrics"])
            {
                self.village.frame = CGRectMake(20,10,280,220);
            }
            else
            {
            }
            
        }
        else if (IS_IPHONE_4)
        {
            if ([practiceName isEqualToString:@"Village Pediatrics (Westport, CT)"])
            {
                self.village.frame = CGRectMake(30,30,260,170);
            }
            else if([practiceName isEqualToString:@"Children's Healthcare Center"])
            {
                self.village.frame = CGRectMake(10,-10,298,250);
            }
            else if([practiceName isEqualToString:@"Brighton Pediatrics"])
            {
                self.village.frame = CGRectMake(10,10,300,200);
            }
            else if ([practiceName isEqualToString:@"Goodtime Pediatrics"])
            {
                self.village.frame = CGRectMake(20,10,280,220);
            }
            else
            {
            }
        
        }
    }
}



@end
