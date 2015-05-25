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
#import "SSZipArchive.h"

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
    NSLog(@"%@",practiceList);
    [self designpack:practiceList];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    NSLog(@"%@",practiceName);
    NSString *practiceLocation = [[practiceList objectAtIndex:indexPath.row] objectForKey:@"location"];;
    NSLog(@"%@",practiceLocation);
    
    [cell.practiceName setText:practiceName];
    [cell.practiceLocation setText:practiceLocation];
    [cell setTag: indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [logic setMainDownloadStarterDelegate:self];
    [logic handleActionWithTag:indexPath.row shouldProceedToPage:FALSE];
    [self.view setUserInteractionEnabled:NO];
    self.navigationItem.hidesBackButton = YES;

    NSString *practiceName = [[practiceList objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSLog(@"%@",practiceName);
    
    NSUserDefaults *indexDefault = [NSUserDefaults standardUserDefaults];
    [indexDefault setObject:practiceName forKey:@"nameOfPratice"];
    [indexDefault synchronize];
    
}



-(void)designpack:(NSArray *)iMagesArray
{
    for (int i =0; i< [iMagesArray count]; i++)
    {
        NSLog(@"%lu",(unsigned long)[iMagesArray count]);
        NSMutableDictionary *ldict = [[NSMutableDictionary alloc]init];
        ldict = [iMagesArray objectAtIndex:i];
        NSString *zipUrl = [ldict objectForKey:@"designPack"];
        NSLog(@"%@",zipUrl);
        //[self SaveFileToResourseFromUrl:zipUrl];
        [self performSelectorInBackground:@selector(SaveFileToResourseFromUrl:) withObject:zipUrl];

    }
}



-(void)SaveFileToResourseFromUrl:(NSString *)zipUrl
{
    //NSURL *url = [[NSURL alloc] initWithString:zipUrl];
    NSURL *url = [[NSURL alloc] initWithString:[zipUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",url);
    NSError *error = nil;
    NSData *data = [NSData  dataWithContentsOfURL:url options:0 error:&error];
    if (!error)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *zipPath = [path stringByAppendingPathComponent:@"zipfile.zip"];
        NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
        
        [data writeToFile:zipPath options:0 error:&error];
        
        if(!error)
        {
            // TODO: Unzip
            [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
            NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzipPath error:&error];
            NSLog(@"the array %@", directoryContents);
            //return YES;
        }
       // else
        //{
          //  NSLog(@"Error saving file %@",error);
          //  return NO;
        //}
    }
   /* else
    {
        NSLog(@"Error downloading zip file: %@", error);
        return NO;
    }*/
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

- (void)switchToIndeterminate {
    [statusHUD setMode:MBProgressHUDModeIndeterminate];
}

- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status {
    [statusHUD setLabelText:@"Downloading..."];
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
    [statusHUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to download files"
                                                    message:@"Please check your internet connection and try again."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self.view setUserInteractionEnabled:YES];
    self.navigationItem.hidesBackButton = NO;
}

@end
