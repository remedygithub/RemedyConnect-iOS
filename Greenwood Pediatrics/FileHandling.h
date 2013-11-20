//
//  FileHandling.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.03..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandling : NSObject

#pragma mark - Methods for interacting with the file system
+(NSString *)getDocumentsPath;
+(NSString *)getFilePathWithComponent:(NSString *)pathComponent;
+(Boolean)doesIndexExists;
+(void)prepareSkinDirectory;
+(NSString *)getEffectiveSkinDirectory;
+(NSString *)getSkinFilePathWithComponent:(NSString *)pathComponent;
+(void)unzipFileInPlace:(NSString *)zipPath;

@end
