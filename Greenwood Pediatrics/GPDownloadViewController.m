//
//  GPViewController.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.02..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "GPDownloadViewController.h"
#import "DataSourceConstants.h"
#import "FileHandling.h"
#import "parserIYCS.h"
#import "Downloader.h"
#import "Data.h"
#import "mainParser.h"

@interface GPDownloadViewController ()

@end

@implementation GPDownloadViewController
Downloader *downloader;
NSMutableData *downloadedData;

- (void)viewDidLoad {
    downloader = [[Downloader alloc] init];
    [downloader setDelegate:self];
    [self setTitle:@"Download database"];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:TRUE];
}

- (IBAction)startDownload:(id)sender {
    [downloader addURLToDownload:[NSString stringWithFormat:@"%@", FEED_ROOT]
                          saveAs:[FileHandling getFilePathWithComponent:@"index.xml"]];
    [downloader startDownload];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[statusHUD removeFromSuperview];
	statusHUD = nil;
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

// DownloaderDelegate
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
    NSString *filePath = [[files objectAtIndex:fileIndex] objectForKey:@"path"];
    mainParser *parser = [[mainParser alloc]
                          initWithXML:filePath];
    if ([parser isMenu]) {
        NSArray *subFeedURLs = [parser getSubFeedURLs];
        for (NSString *URL in subFeedURLs) {
            [downloader addURLToDownload:URL saveAs:[mainParser subFeedURLToLocal:URL]];
        }
    }
    if ([[downloader status] currentFileIndex] + 1 <
             [[downloader status] numberOfFilesToDownload]) {
        [downloader startNextDownload];
    }
    else {
        [statusHUD setLabelText:@"Finished!"];
        [statusHUD hide:YES afterDelay:2];
    }
}

- (void)hasFailedToDownloadAFile {
    [statusHUD setLabelText:@"Failed to download files.\nPlease try again later."];
    [statusHUD hide:YES afterDelay:2];
}
@end
