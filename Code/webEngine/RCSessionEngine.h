//
//  RCSessionEngine.h
//  YourPractice
//
//  Created by Ravindra Kishan on 22/05/15.
//  Copyright (c) 2015 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macros.h"

#define TestUrl     @"https://tsapitest.remedyconnect.com/api"
#define ProdUrl     @"https://api.remedyoncall.com/api"
#define apiUrl TestUrl

@protocol SessionEngineDelegate <NSObject>
-(void)SessionManagerDidReceiveResponse:(NSDictionary*)pResultDict;
-(void)SessionManagerDidFailWithError:(NSError *)error;
@end

@interface RCSessionEngine : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
}

+(RCSessionEngine *)SharedWebEngine;

@property (nonatomic, readwrite) NSInteger code;
@property (nonatomic, strong)  NSString *userId;
@property (nonatomic, strong) id<SessionEngineDelegate> delegate;
@property (nonatomic, strong) NSMutableData *m_cReceivedData;


//Methods
-(void)getLoginInTimeOutDetails;
-(void)LogoutTheUser;

@end
