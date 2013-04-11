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
    [downloader addURLToDownload:[NSString stringWithFormat:@"%@%@", link_base, iycs]
                          saveAs:[FileHandling getFilePathWithComponent:@"iycs.xml"]];
    [downloader addURLToDownload:[NSString stringWithFormat:@"%@%@", link_base, office]
                          saveAs:[FileHandling getFilePathWithComponent:@"office.xml"]];
    [downloader addURLToDownload:[NSString stringWithFormat:@"%@%@", link_base, location]
                          saveAs:[FileHandling getFilePathWithComponent:@"location.xml"]];
    [downloader addURLToDownload:[NSString stringWithFormat:@"%@%@", link_base, news]
                          saveAs:[FileHandling getFilePathWithComponent:@"news.xml"]];
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
    if ([[downloader status] currentFileIndex] == 0) {
        parserIYCS *parser = [[parserIYCS alloc] init];
        NSArray *categories = [parser getCategories];
        for (NSDictionary *category in categories) {
            NSString *categoryid = [category objectForKey:@"categoryid"];
            NSString *URL = [NSString stringWithFormat:@"%@%@/%@", link_base, iycs, categoryid];
            [downloader addURLToDownload:URL
                                  saveAs:[FileHandling IYCScategoryIDtoFileName:categoryid]];
        }
        [downloader startNextDownload];
    }
    else if ([[downloader status] currentFileIndex] + 1 <
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
