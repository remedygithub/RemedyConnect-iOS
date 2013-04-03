//
//  GPViewController.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.02..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "GPViewController.h"
#import "DataSourceConstants.h"
#import "FileHandling.h"
#import "parserIYCS.h"

@interface GPViewController ()

@end

@implementation GPViewController

long long expectedLength;
long long currentLength;
NSMutableData *downloadedData;

- (IBAction)startDownload:(id)sender {
    NSURL *urlToDownload = [NSURL URLWithString:
                            [NSString stringWithFormat:
                             @"%@%@", link_base, iycs]];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlToDownload];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD setLabelText:@"Starting download..."];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [statusHUD setMode:MBProgressHUDModeDeterminate];
    expectedLength = [response expectedContentLength];
	currentLength = 0;
    downloadedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    currentLength += [data length];
	statusHUD.progress = currentLength / (float)expectedLength;
    [downloadedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [statusHUD setLabelText:@"Download finished!"];
    NSError *saveError;
    NSString *filePath = [FileHandling getFilePathWithComponent:@"iycs.xml"];
    if ([downloadedData writeToFile:filePath options:NSDataWritingAtomic error:&saveError] == YES) {
        [statusHUD setLabelText:@"Saved data, starting parse..."];
        NSLog(@"Downloaded %lld bytes of data to %@.", currentLength, filePath);
        parserIYCS *parser = [[parserIYCS alloc] init];
        NSArray *categories = [parser getCategories];
        for (NSString *category in categories) {
            NSLog(@"Talált kategória: %@", category);
        }
        [statusHUD setLabelText:@"Parsed ;)"];
        [statusHUD hide:YES afterDelay:2];
    }
    else {
        [statusHUD setLabelText:@"Save failed :("];
        [statusHUD hide:YES afterDelay:2];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [statusHUD hide:YES];
    downloadedData = nil;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[statusHUD removeFromSuperview];
	statusHUD = nil;
}
@end
