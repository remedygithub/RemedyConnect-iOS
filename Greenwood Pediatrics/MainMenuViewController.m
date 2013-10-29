//
//  MainMenuViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SelectPracticeTableViewController.h"
#import "FileHandling.h"
#import "Data.h"
#import "mainParser.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController
Downloader *downloader;
NSMutableData *downloadedData;
NSArray *testData;
NSString *filePath;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:TRUE];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:FALSE animated:TRUE];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:TRUE];
}

- (IBAction)startDownloading:(id)sender {
    downloader = [[Downloader alloc] init];
    [downloader setDelegate:self];
    [downloader addURLToDownload:[NSString stringWithFormat:@"%@", FEED_ROOT]
                          saveAs:[FileHandling getFilePathWithComponent:@"index.xml"]];
    [downloader startDownload];
    
    testData = [[NSArray alloc]
                         initWithObjects:@"Practice 1",
                         @"Practice2", @"Practice3", nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectPracticeSegue" ]) {
        mainParser *parser = [[mainParser alloc] initWithXML:filePath];
        if ([parser isRoot]) {
            NSArray *practices = [parser getRootPractices];
            NSMutableArray *practiceNames = [[NSMutableArray alloc] init];
            NSMutableArray *practiceLocations =  [[NSMutableArray alloc] init];
            for (NSDictionary *practice in practices) {
                [practiceNames addObject:[practice objectForKey:@"name"]];
                [practiceLocations addObject:[practice objectForKey:@"location"]];
            }
            SelectPracticeTableViewController *sp = segue.destinationViewController;
            sp.practiceNames = [[NSArray alloc] initWithArray:practiceNames];
            sp.practiceLocations = [[NSArray alloc] initWithArray:practiceLocations];
        }
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[statusHUD removeFromSuperview];
	statusHUD = nil;
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

#pragma mark "DownloaderDelegate"
- (void)hasStartedDownloadingFirst {
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD setLabelText:@"Starting download..."];
}

- (void)hasStartedDownloadingNext {
    [statusHUD setMode:MBProgressHUDModeIndeterminate];
}

- (void)didReceiveResponseForAFile {
    [statusHUD setMode:MBProgressHUDModeDeterminate];
    [statusHUD setLabelText:
     [[NSString alloc] initWithFormat:@"Downloading %d/%d...",
      [[downloader status] currentFileIndex] + 1,
      [[downloader status] numberOfFilesToDownload]]];
}

- (void)didReceiveDataForAFile {
    if ([[downloader status] expectedLength] > 0) {
        statusHUD.progress =
        [[downloader status] currentLength] /
        (float)[[downloader status] expectedLength];
    }
}

- (void)didFinishForAFile {
    NSArray *files = [downloader filesToDownload];
    NSUInteger fileIndex = [[downloader status] currentFileIndex];
    filePath = [[files objectAtIndex:fileIndex] objectForKey:@"path"];
    if ([[downloader status] currentFileIndex] + 1 <
        [[downloader status] numberOfFilesToDownload]) {
        [downloader startNextDownload];
    }
    else {
        [statusHUD setLabelText:@"Finished!"];
        [statusHUD hide:YES afterDelay:2];
        [self performSegueWithIdentifier:@"selectPracticeSegue" sender:self];
    }
}

- (void)hasFailedToDownloadAFile {
    [statusHUD setLabelText:@"Failed to download files.\nPlease try again later."];
    [statusHUD hide:YES afterDelay:2];
}
@end
