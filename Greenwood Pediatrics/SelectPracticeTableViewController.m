//
//  SelectPracticeTableViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.18..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "SelectPracticeTableViewController.h"
#import "SelectYourPracticeTableCell.h"
#import "Logic.h"

@interface SelectPracticeTableViewController ()

@end

@implementation SelectPracticeTableViewController

@synthesize searchString;

NSArray *practiceList;

Logic *logic;

#pragma mark - Table view data source

- (void)viewDidLoad {
    logic = [Logic sharedLogic];
    practiceList = [logic getPracticeList];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [practiceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"practiceCell";
    SelectYourPracticeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                        forIndexPath:indexPath];

    NSString *practiceName = [[practiceList objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString *practiceLocation = [[practiceList objectAtIndex:indexPath.row] objectForKey:@"location"];;
    [cell.practiceName setText:practiceName];
    [cell.practiceLocation setText:practiceLocation];
    [cell setTag: indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [logic setMainDownloadStarterDelegate:self];
    [logic handleActionWithTag:indexPath.row shouldProceedToPage:FALSE];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[statusHUD removeFromSuperview];
	statusHUD = nil;
}

#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading {
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD setLabelText:@"Starting download..."];
}

- (void)switchToIndeterminate {
    [statusHUD setMode:MBProgressHUDModeIndeterminate];
}

- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status {
    [statusHUD setMode:MBProgressHUDModeDeterminate];
    [statusHUD setLabelText:
     [[NSString alloc] initWithFormat:@"Downloading %d/%d...",
      [status currentFileIndex] + 1,
      [status numberOfFilesToDownload]]];
}

- (void)updateProgress:(DownloadStatus *)status {
    if ([status expectedLength] > 0) {
        statusHUD.progress = [status currentLength] / (float)[status expectedLength];
    }
}

- (void)didFinish {
    [statusHUD setMode:MBProgressHUDModeText];
    [statusHUD setLabelText:@"Finished!"];
    [statusHUD hide:YES afterDelay:2];
}

- (void)hasFailed {
    [statusHUD setLabelText:@"Failed to download files.\nPlease try again later."];
    [statusHUD hide:YES afterDelay:2];
}

@end
