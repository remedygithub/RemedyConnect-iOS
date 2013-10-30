//
//  SelectPracticeTableViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.18..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "SelectPracticeTableViewController.h"
#import "SelectYourPracticeTableCell.h"
#import "parser/mainParser.h"
#import "FileHandling.h"
#import "Data.h"

@interface SelectPracticeTableViewController ()

@end

@implementation SelectPracticeTableViewController

@synthesize practiceNames;
@synthesize practiceLocations;
@synthesize practiceFeeds;
@synthesize practiceDesignPacks;

Downloader *downloader;
NSMutableData *downloadedData;

#pragma mark - Table view data source

- (void)viewDidLoad {
    downloader = [[Downloader alloc] init];
    [downloader setDelegate:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [practiceNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"practiceCell";
    SelectYourPracticeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                        forIndexPath:indexPath];

    [cell.practiceName setText:[practiceNames objectAtIndex:indexPath.row]];
    [cell.practiceLocation setText:[practiceLocations objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)prepareSkinDirectory {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/skin"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil error:&error];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *feedURL = [practiceFeeds objectAtIndex:indexPath.row];
    NSString *designPackURL = [practiceDesignPacks objectAtIndex:indexPath.row];
    [self prepareSkinDirectory];
    [Data saveFeedRoot:feedURL];
    [Data saveDesignPackURL:designPackURL];
    [downloader addURLToDownload:feedURL
                          saveAs:[FileHandling getFilePathWithComponent:@"index.xml"]];
    [downloader addURLToDownload:designPackURL
                          saveAs:[FileHandling getFilePathWithComponent:@"skin/DesignPack.zip"]];
    [downloader startDownload];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[statusHUD removeFromSuperview];
	statusHUD = nil;
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

#pragma mark DownloaderDelegate
- (void)hasStartedDownloadingFirst {
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD setLabelText:@"Starting download data..."];
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
    NSString *filePath = [[files objectAtIndex:fileIndex] objectForKey:@"path"];
    mainParser *parser = [[mainParser alloc]
                          initWithXML:filePath];
    if ([parser isMenu]) {
        NSArray *subFeedURLs = [parser getSubFeedURLs];
        for (NSString *URL in subFeedURLs) {
            // Have to do the following check, this might be empty because of externalLinks...
            if (![URL isEqualToString:@""]) {
                [downloader addURLToDownload:URL
                                      saveAs:[mainParser subFeedURLToLocal:URL withFeedRoot:[Data getFeedRoot]]];
            }
        }
    }
    if ([[downloader status] currentFileIndex] + 1 <
        [[downloader status] numberOfFilesToDownload]) {
        [downloader startNextDownload];
    }
    else {
        [statusHUD setMode:MBProgressHUDModeText];
        [statusHUD setLabelText:@"Finished!"];
        [statusHUD hide:YES afterDelay:2];
    }
}

- (void)hasFailedToDownloadAFile {
    [statusHUD setLabelText:@"Failed to download files.\nPlease try again later."];
    [statusHUD hide:YES afterDelay:2];
}

@end
