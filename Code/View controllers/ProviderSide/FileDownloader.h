//
//  FileDownloader.h
//  demoROC
//
//  Created by Ravindra Kishan on 30/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMLDictionary.h"
#import "Practice.h"
#import "RCHelper.h"
#import "MBProgressHUD.h"
#import "YourPracticeAppDelegate.h"

@protocol FileDownloaderDelegate <NSObject>
//-(void)successfullyParsedFiles:(Practice *)practice;
-(void)successfullyParsedFiles:(NSMutableArray *)practiceInfo modelData:(Practice *)practice;
-(void)practiceNotFound;
@end

@interface FileDownloader : NSObject<NSXMLParserDelegate,MBProgressHUDDelegate>
{
    NSMutableArray *feedArray;
    RCHelper *helperClass;
    MBProgressHUD *statusHUD;

}
@property(nonatomic, strong) id <FileDownloaderDelegate> delegate;

+(FileDownloader *)SharedInstance;
-(void)downloadFileAndParseFrom:(NSString *)lExtension;
-(void)downloadFileAndParseFromLocation:(float)latitude locationLongitude:(float)longitude;
-(BOOL)SaveFileToResourseFromUrl:(NSString *)zipUrl;

@end
