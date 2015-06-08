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

    self.dummyArray = [[NSMutableArray alloc]initWithObjects:@"John Calvin",@"Srinivasan Murthy",@"Marie Joseph",@"Mark Steve",nil];
    self.dummyMsgArray = [[NSMutableArray alloc]initWithObjects:@"Need Appointment for Uncle",@"Medicare Inquiry",@"Need Diet Information for 12 year Boy",@"Bill payment Issue", nil];
    [self.navigationController setNavigationBarHidden:YES];
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
    return [self.dummyArray count];
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
  
    cell.fNameAndLName.text = [self.dummyArray objectAtIndex:indexPath.row];
    cell.descpLabel.text =    [self.dummyMsgArray objectAtIndex:indexPath.row];
    cell.timeLabel.text = @"8Jun 15 - 02:15PM";
    return cell;
}


//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self getNameDetails:self.dummyArray getMessageDetails:self.dummyMsgArray dataIndex:indexPath.row];
//}


-(void)getNameDetails:(NSMutableArray *)detail  getMessageDetails:(NSMutableArray *)messageDetail  dataIndex:(NSInteger)index
{
    help =[[RCHelper alloc]init];
    help.string1= [detail objectAtIndex:index];
    help.string2 = [messageDetail objectAtIndex:index];
    [self performSegueWithIdentifier:@"MoveToMessageDetail" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MoveToMessageDetail"])
    {
        MessageDetailsViewController *detail = (MessageDetailsViewController*)segue.destinationViewController;
        detail.self.str1 = help.string1;
        NSLog(@"%@",detail.self.str1);
        detail.self.str2 = help.string2;
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

@end
