//
//  MessageListViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 09/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "MessageListViewController.h"

@interface MessageListViewController (){
}
@property (nonatomic, strong)PopoverView *mPopver;
@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    logic = [Logic sharedLogic];
    self.dataArray = [[NSMutableArray alloc]init];
    [self.navigationController setNavigationBarHidden:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([self class]) forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetAction)
                                                 name:kResetPinNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMessageList)
                                                 name:kNewArrivedMessageCount
                                               object:nil];
    
    self.messageTableView.contentSize = CGSizeMake(320, 540);

    [self displayImages];
    [self getUserLoginSession];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

-(void)getUserLoginSession
{
    [self hasStartedDownloading:@"Refreshing Messages"];
    [RCPinEngine SharedWebEngine].delegate = self;
    [[RCPinEngine SharedWebEngine]checkLoginSessionOfUser];
}

-(void)LogoutTheUser
{
    
    if ([RCPracticeHelper SharedHelper].isLogout || [RCPracticeHelper SharedHelper].isPinFailureAttempt || [RCPracticeHelper SharedHelper].isLoginTimeOut)
    {
        [self hasStartedDownloading:@"Logging Out..."];
    }
    [RCSessionEngine SharedWebEngine].delegate = self;
    [[RCSessionEngine SharedWebEngine] LogoutTheUser];
}


-(void)displayImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    NSString *imageFilePath = [unzipPath stringByAppendingPathComponent:@"background_main.png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
    UIImage *img = [UIImage imageWithData:imageData];

    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       self.messageTableView.backgroundView = [[UIImageView alloc] initWithImage:img];
                   });
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_selectedIndexPathRow)
    {
        [self moveCellRowToSelectedIndex:_selectedIndexPathRow];
    }
    
        NSLog(@"%s",__PRETTY_FUNCTION__);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"BackToHome"];
    [defaults synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([self class]) forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)appEnteredForeground
{
    [[UIApplication sharedApplication].delegate performSelector:@selector(applicationDidTimeout)];
}

- (IBAction)backBtnTapped:(id)sender
{
    BOOL Back = [[NSUserDefaults standardUserDefaults]objectForKey:@"BackToHome"];
    if (Back)
    {
        UIViewController *controller =  [self.storyboard instantiateViewControllerWithIdentifier:@"ProviderHomeViewController"];
        [self.navigationController pushViewController:controller animated:NO];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"BackToHome"];
        
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
            [self performSegueWithIdentifier:@"FromMessageListToTerms" sender:self];
            break;
            
//        case 3:
//            [self performSegueWithIdentifier:@"FromMessageListToAbout" sender:self];
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

#pragma UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MessageListCell *cell = (MessageListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageListCell" owner:self options:nil];
        cell = [nib objectAtIndex: 0];
    }
  
    RCHelper *messageInfo = [self.dataArray objectAtIndex:indexPath.row];
   
    cell.fNameAndLName.text = [NSString stringWithFormat:@"%@ %@",messageInfo.messageFName, messageInfo.messageLName];
    cell.descpLabel.text = messageInfo.messageDetails;
    cell.timeLabel.text = messageInfo.messageDate;
    NSString *iConID = [NSString stringWithFormat:@"%@",messageInfo.callerTypeID];
    NSString *urgentID = [NSString stringWithFormat:@"%@",messageInfo.urgentId];
    NSString *readID = [NSString stringWithFormat:@"%@",messageInfo.messageOpened];
   
    NSLog(@"%@",iConID);
    NSLog(@"%@",urgentID);
    NSLog(@"message opened:%@",readID);

     if ([iConID isEqualToString:@"1"])
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];
         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"patientNew.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"patientNew.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];
         }
     }
    
    
     if ([iConID isEqualToString:@"2"] )
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"providerNew.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"providerNew.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }
     }
    
    
     if ([iConID isEqualToString:@"3"])
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"Newborn.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"Newborn.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }

     }
    
     if ([iConID isEqualToString:@"4"] )
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"rx_refill.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"rx_refill.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }

     }
    
    
    
     if ([iConID isEqualToString:@"5"])
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"answering_service.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"answering_service.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }

     }
   
    
    
     if ([iConID isEqualToString:@"6"] )
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"triage.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"triage.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }

     }
    
    
     if ([iConID isEqualToString:@"14"])
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"rounding_doctor.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"rounding_doctor.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }

     }
    
    
     if ([iConID isEqualToString:@"15"])
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"] )
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];

         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"hospital_admission.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"hospital_admission.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];
         }

     }
    
    
    if ([iConID isEqualToString:@"16"])
    {
        if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"] )
        {
            cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
            cell.readImage.image = [UIImage imageNamed:@""];
        }
        else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
        {
            cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
            cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];
            
        }
        else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
        {
            cell.iConImage.image = [UIImage imageNamed:@"Roundingdoctor.png"];
            cell.readImage.image = [UIImage imageNamed:@""];
        }
        else
        {
            cell.iConImage.image = [UIImage imageNamed:@"Roundingdoctor.png"];
            cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];
        }
        
    }
    
     if ([iConID isEqualToString:@"17"])
     {
         if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"1"] )
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else if ([urgentID isEqualToString:@"1"] && [readID isEqualToString:@"0"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"urgent_message.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];
         }
         else if ([urgentID isEqualToString:@"0"] && [readID isEqualToString:@"1"])
         {
             cell.iConImage.image = [UIImage imageNamed:@"appointment.png"];
             cell.readImage.image = [UIImage imageNamed:@""];
         }
         else
         {
             cell.iConImage.image = [UIImage imageNamed:@"appointment.png"];
             cell.readImage.image = [UIImage imageNamed:@"yellow_Unread.png"];
         }
     }
        return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RCHelper *messageInfo = [self.dataArray objectAtIndex:indexPath.row];
    messageInfo.messageOpened = @"1";
    [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     _selectedIndexPathRow = indexPath;
     NSLog(@"%@",_selectedIndexPathRow);
    
     messageHelper = [self.dataArray objectAtIndex:indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:messageHelper.messageDetails forKey:@"Details"];
    [defaults setObject:messageHelper.phoneNumber forKey:@"phoneNumber"];
    [defaults setObject:messageHelper.callerId forKey:@"CallerID"];
    [defaults synchronize];
    [self performSegueWithIdentifier:@"MoveToMessageDetail" sender:self];
}


-(void)moveCellRowToSelectedIndex:(NSIndexPath *)selectedPath
{
    [self.messageTableView selectRowAtIndexPath:selectedPath
                           animated:NO
                     scrollPosition:UITableViewScrollPositionMiddle];
}



#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MoveToMessageDetail"])
    {
        MessageDetailsViewController *detail = (MessageDetailsViewController*)segue.destinationViewController;
        detail.selectedIndex = _selectedIndexPathRow;
        detail.messageDetailHelper = messageHelper;
    }
    if ([segue.identifier isEqualToString:@"FromMessageListToAbout"])
    {
        AboutUsViewController *aboutController = [segue destinationViewController];
        aboutController.self.Text = @"About";
    }
    if ([segue.identifier isEqualToString:@"FromMessageListToTerms"])
    {
        AboutUsViewController *termsController = [segue destinationViewController];
        termsController.self.Text = @"Legal";
    }
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


-(void)getMessageList
{
    _selectedIndexPathRow = nil;
    [statusHUD hide:YES afterDelay:1.0];
    [RCWebEngine SharedWebEngine].delegate = self;
    [[RCWebEngine SharedWebEngine] getMessageListInformation];
}


#pragma mark - PinEngine Delegate
-(void)PinManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    if ([[pResultDict objectForKey:@"successfull"]integerValue])
    {
        [self getMessageList];
        NSString * messageCount = [NSString stringWithFormat:@"%@",[pResultDict objectForKey:@"count"]];
        NSLog(@"Damm %@",messageCount);
        [UIApplication sharedApplication].applicationIconBadgeNumber = [messageCount integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:[messageCount integerValue] forKey:@"BadgeCount"];;
    }
    else
    {
        [RCPracticeHelper SharedHelper].isChangePractice =NO;
        [RCPracticeHelper SharedHelper].isLogout =NO;
        [RCPracticeHelper SharedHelper].isApplicationMode = NO;
        [RCPracticeHelper SharedHelper].isPinFailureAttempt = NO;
        [RCPracticeHelper SharedHelper].isLoginTimeOut = YES;
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Your session has expired" message:@"You will need to login again. Please press OK to proceed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 10;
        [alert show];
    }
}



-(void)PinManagerDidFailWithError:(NSError *)error
{
    [statusHUD hide:YES afterDelay:2];
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10 && buttonIndex == 0)
    {
        [self LogoutTheUser];
    }
}

#pragma mark - Connection Manager 
-(void)connectionManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    [statusHUD hide:YES afterDelay:1];
    [self.dataArray removeAllObjects];

    [RCHelper SharedHelper].isFromDetailMessage = NO;
    if ([[pResultDict objectForKey:@"successfull"]boolValue])
    {
        for (int i=0 ; i <[[pResultDict objectForKey:@"messages"] count]; i++)
        {
            messageHelper = [[RCHelper alloc]init];
            messageHelper.messageFName = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i] objectForKey:@"callerFirstName"];
            NSLog(@"%@",messageHelper.messageFName);
            messageHelper.messageLName = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i]objectForKey:@"callerLastName"];
            messageHelper.messageDate = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i]objectForKey:@"messageDate"];
            messageHelper.messageDetails = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i]objectForKey:@"message"];
             messageHelper.callerTypeID = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i]objectForKey:@"callTypeId"];
             messageHelper.phoneNumber = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i]objectForKey:@"phone"];
            messageHelper.urgentId = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i]objectForKey:@"urgent"];
            messageHelper.callerId = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i]objectForKey:@"callID"];
            messageHelper.messageOpened = [[[pResultDict objectForKey:@"messages"] objectAtIndex:i]objectForKey:@"wasOpened"];
            [self.dataArray addObject:messageHelper];
            NSLog(@"%lu",(unsigned long)[self.dataArray count]);
        }
    }
    [self.messageTableView reloadData];
    if (_selectedIndexPathRow)
    {
        [self moveCellRowToSelectedIndex:_selectedIndexPathRow];
    }
    
   
}

-(void)connectionManagerDidFailWithError:(NSError *)error
{
    [statusHUD hide:YES afterDelay:2];
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}


-(void)clearData
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:KLastLaunchedController];
    [[NSUserDefaults standardUserDefaults]synchronize];
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
            [[RCHelper SharedHelper] setUserWithUserName:[userDict valueForKey:kUserName] andPin:nil andLoggedIN:YES];
            [self performSegueWithIdentifier:@"MoveToMessageListToSearch" sender:self];
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
        self.messageTableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.frame.size.height-64, 0);
    }
    else
    {
        NSLog(@"Portrait");
        self.messageTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}
@end
