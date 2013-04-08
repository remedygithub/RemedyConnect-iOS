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
    NSMutableArray *filesToDownload;
    NSMutableData *downloadedData;
}

- (id)init {
    self = [super init];
    if (self) {
        filesToDownload = [[NSMutableArray alloc] init];
        status = [[DownloadStatus alloc] init];
    }
    return self;
}

@synthesize delegate;
@synthesize status;

- (void)addURLToDownload:(NSString *)URL saveAs:(NSString *)path {
    NSMutableDictionary *URLandPath = [[NSMutableDictionary alloc] init];
    [URLandPath setValue:URL forKey:@"URL"];
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
        NSURLRequest *request = [NSURLRequest requestWithURL:urlToDownload];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *URLandPath = [filesToDownload objectAtIndex:[[self status] currentFileIndex]];
    NSString *filePath = [URLandPath objectForKey:@"path"];
    NSError *error;
    [downloadedData writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    if ([[self delegate] respondsToSelector:@selector(didFinishForAFile)]) {
        [[self delegate] didFinishForAFile];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    downloadedData = nil;
    if ([[self delegate] respondsToSelector:@selector(hasFailedToDownloadAFile)]) {
        [[self delegate] hasFailedToDownloadAFile];
    }
}

@end
