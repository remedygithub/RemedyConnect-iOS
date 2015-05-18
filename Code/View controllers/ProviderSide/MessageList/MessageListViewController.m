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

    self.dummyArray = [[NSMutableArray alloc]initWithObjects:@"John Calvin",@"Srinivasan",@"Marie",@"Mark Steve",nil];
    self.dummyMsgArray = [[NSMutableArray alloc]initWithObjects:@"Need Appointment for Uncle",@"Medicare Inquiry",@"Need Diet Information for 12 year Boy",@"Bill payment Issue", nil];
    NSString * pratice = [[NSUserDefaults standardUserDefaults] objectForKey:@"messageLabel"];
    self.practiceNameLabel.text = pratice;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)backBtnTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)menuBtnTapped:(id)sender
{
    
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*CellIdentifer = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifer];
    }
    cell.textLabel.text = [self.dummyArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.dummyMsgArray objectAtIndex:indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getNameDetails:self.dummyArray getMessageDetails:self.dummyMsgArray dataIndex:indexPath.row];
}


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


@end
