//
//  DownloadStatus.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.05..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadStatus : NSObject
@property (nonatomic) long long expectedLength;
@property (nonatomic) long long currentLength;
@property (nonatomic) NSUInteger numberOfFilesToDownload;
@property (nonatomic) NSUInteger currentFileIndex;
@end
