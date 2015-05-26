//
//  Downloader.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.04..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "Downloader.h"
#import "FileHandling.h"

@implementation Downloader
{
    NSMutableData *downloadedData;
}

@synthesize filesToDownload;
@synthesize delegate;
@synthesize status;

const int TIMEOUT_INTERVAL = 120;

- (id)init {
    self = [super init];
    if (self) {
        filesToDownload = [[NSMutableArray alloc] init];
        status = [[DownloadStatus alloc] init];
    }
    return self;
}

- (void)addURLToDownload:(NSString *)URL saveAs:(NSString *)path {
    NSMutableDictionary *URLandPath = [[NSMutableDictionary alloc] init];
    [URLandPath setValue:URL forKey:@"URL"];
    //NSString
    [URLandPath setValue:path forKey:@"path"];
    [filesToDownload addObject:URLandPath];
    [[self status]
        setNumberOfFilesToDownload:[[self status] numberOfFilesToDownload]+1];
}

- (void)startDownload {
    [self downloadFile:0];
    if ([[self delegate] respondsToSelector:@selector(hasStartedDownloadingFirst)]) {
        [[self delegate] hasStartedDownloadingFirst];
    }
}

- (void)startNextDownload {
    NSUInteger currentIndex = [[self status] currentFileIndex];
    if ([filesToDownload count]-1 > currentIndex) {
        ++currentIndex;
        [[self status] setCurrentFileIndex:currentIndex];
        [self downloadFile:currentIndex];
        if ([[self delegate] respondsToSelector:@selector(hasStartedDownloadingNext)]) {
            [[self delegate] hasStartedDownloadingNext];
        }
    }
}

- (void)downloadFile:(NSUInteger)index {
    NSDictionary *URLandPath;
    if ((URLandPath = [filesToDownload objectAtIndex:index])) {
        NSURL *urlToDownload =
            [NSURL URLWithString:[URLandPath objectForKey:@"URL"]];

        NSURLRequest *request = [NSURLRequest requestWithURL:urlToDownload
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:TIMEOUT_INTERVAL];
        NSURLConnection *connection =
            [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
    }
}

- (Boolean)isDownloadingNecessary:(NSArray *)filesToCheck {
    for (NSString *path in filesToCheck) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return true;
        }
    }
    return false;
}

- (void)shutdownOnFailure {
    downloadedData = nil;
    if ([[self delegate] respondsToSelector:@selector(hasFailedToDownloadAFile)]) {
        [[self delegate] hasFailedToDownloadAFile];
    }
}

// NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    downloadedData = [[NSMutableData alloc] init];
    [[self status] setExpectedLength:[response expectedContentLength]];
    [[self status] setCurrentLength:0];
    if ([[self delegate] respondsToSelector:@selector(didReceiveResponseForAFile)]) {
        [[self delegate] didReceiveResponseForAFile];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [downloadedData appendData:data];
    [[self status] setCurrentLength:
        [[self status] currentLength] + [data length]];
    if ([[self delegate] respondsToSelector:@selector(didReceiveDataForAFile)]) {
        [[self delegate] didReceiveDataForAFile];
    }
}

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([[challenge protectionSpace] authenticationMethod] == NSURLAuthenticationMethodServerTrust) {
        
        [[challenge sender] useCredential:[NSURLCredential credentialForTrust:[[challenge protectionSpace] serverTrust]] forAuthenticationChallenge:challenge];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *URLandPath = [filesToDownload objectAtIndex:[[self status] currentFileIndex]];
    NSString *filePath = [URLandPath objectForKey:@"path"];
    NSError *error;
    [downloadedData writeToFile:filePath options:NSDataWritingAtomic error:&error];
    // After writing the file out, we need to set to exclude it from the backups
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [fileURL setResourceValue:[NSNumber numberWithBool:YES]
                                            forKey:NSURLIsExcludedFromBackupKey
                                             error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    if ([[self delegate] respondsToSelector:@selector(didFinishForAFile)])
    {
        [[self delegate] didFinishForAFile];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Download error: %@", error.description);
    [self shutdownOnFailure];
}

@end
