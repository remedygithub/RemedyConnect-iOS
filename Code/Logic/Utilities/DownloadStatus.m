//
//  DownloadStatus.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.05..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "DownloadStatus.h"

@implementation DownloadStatus
@synthesize expectedLength;
@synthesize currentLength;
@synthesize numberOfFilesToDownload;
@synthesize currentFileIndex;

- (id)init {
    return [self initWithExpectedLength:0 numberOfFilesToDownload:0];
}

- (id)initWithExpectedLength:(long long)lengthExpected
        numberOfFilesToDownload:(NSInteger)filesToDownload {
    self = [super init];
    if (self) {
        [self setExpectedLength:lengthExpected];
        [self setNumberOfFilesToDownload:filesToDownload];
        [self setCurrentFileIndex:0];
        [self setCurrentLength:0];
    }
    return self;
}
@end
