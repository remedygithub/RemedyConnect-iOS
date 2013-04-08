//
//  Downloader.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.04..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "DownloadStatus.h"

@protocol DownloaderDelegate <NSObject>
@optional
- (void)hasStartedDownloadingFirst;
- (void)hasStartedDownloadingNext;
- (void)didReceiveResponseForAFile;
- (void)didReceiveDataForAFile;
- (void)didFinishForAFile;
- (void)hasFailedToDownloadAFile;
@end


@interface Downloader : NSObject <NSURLConnectionDelegate>
@property (nonatomic, weak) id <DownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) DownloadStatus *status;

- (void)addURLToDownload:(NSString *)URL saveAs:(NSString *)path;
- (void)startDownload;
- (void)startNextDownload;
- (Boolean)isDownloadingNecessary:(NSArray *)filesToCheck;

// NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection
        didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection
        didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection
        didFailWithError:(NSError *)error;
@end
