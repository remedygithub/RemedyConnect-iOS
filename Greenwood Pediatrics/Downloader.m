//
//  Downloader.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.04..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "Downloader.h"

@implementation Downloader
{
    NSMutableArray *filesToDownload;
}

- (id)init {
    self = [super init];
    if (self) {
        filesToDownload = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addURLToDownloadAndSaveAs:(NSString *)URL saveAs:(NSString *)path {
    NSMutableDictionary *URLandPath = [[NSMutableDictionary alloc] init];
    [URLandPath setValue:URL forKey:@"URL"];
    [URLandPath setValue:path forKey:@"path"];
    [filesToDownload addObject:URLandPath];
}

// NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Could not download, fail and exit the app?
}

@end
