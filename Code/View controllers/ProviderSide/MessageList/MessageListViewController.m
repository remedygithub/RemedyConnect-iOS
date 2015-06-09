//
//  MessageListViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 09/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "MessageListViewController.h"

@interface MessageListViewController ()

@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    logic = [Logic sharedLogic];
    self.dataArray = [[NSMutableArray alloc]init];
    [self.navigationController setNavigationBarHidden:YES];
    [self getMessageList];
}

-(void)getMessageList
{
    [self hasStartedDownloading:@"Refreshing Messages"];
    [RCWebEngine SharedWebEngine].delegate = self;
    [[RCWebEngine SharedWebEngine] getMessageListInformation];
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
            [self performSegueWithIdentifier:@"FromMessageListToTerms" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"FromMessageListToAbout" sender:self];
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
    return 80;
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
    NSLog(@"%@",iConID);
    if ([iConID isEqualToString:@"1"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"Patient.png"];
    }
    else if ([iConID isEqualToString:@"2"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"Provider.png"];
    }
    else if ([iConID isEqualToString:@"3"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"Newborn.png"];
    }
    else if ([iConID isEqualToString:@"4"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"RxRefill.png"];
    }
    else if ([iConID isEqualToString:@"5"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"AnsweringService.png"];
    }
    else if ([iConID isEqualToString:@"6"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"Triage.png"];
    }
    else if ([iConID isEqualToString:@"7"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"Roundingdoctor.png"];
    }
    else if ([iConID isEqualToString:@"8"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"HospitalAdmission.png"];
    }
    else if ([iConID isEqualToString:@"9"])
    {
        cell.iConImage.image = [UIImage imageNamed:@"Appointment.png"];
    }
    else
    {
        cell.iConImage.image = [UIImage imageNamed:@"Urgent.png"];
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     messageHelper = [self.dataArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"MoveToMessageDetail" sender:self];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MoveToMessageDetail"])
    {
        MessageDetailsViewController *detail = (MessageDetailsViewController*)segue.destinationViewController;
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
        termsController.self.Text = @"Terms and Conditions";
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


#pragma mark - Connection Manager 
-(void)connectionManagerDidReceiveResponse:(NSDictionary *)pResultDict
{
    [statusHUD hide:YES afterDelay:1];
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
            [self.dataArray addObject:messageHelper];
            NSLog(@"%lu",(unsigned long)[self.dataArray count]);

        }
    }
    [self.messageTableView reloadData];
}

-(void)connectionManagerDidFailWithError:(NSError *)error
{
    [statusHUD hide:YES afterDelay:2];
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ Please try later", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}
@end
