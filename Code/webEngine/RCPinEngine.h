//
//  RCPinEngine.h
//  YourPractice
//
//  Created by Ravindra Kishan on 08/06/15.
//  Copyright (c) 2015 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macros.h"

#define TestUrl     @"https://tsapitest.remedyconnect.com/api"
#define ProdUrl     @"https://api.remedyoncall.com/api"
#define apiUrl TestUrl

@protocol PinEngineDelegate <NSObject>
-(void)PinManagerDidReceiveResponse:(NSDictionary*)pResultDict;
-(void)PinManagerDidFailWithError:(NSError *)error;
@end

@interface RCPinEngine : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
}

+(RCPinEngine *)SharedWebEngine;

@property (nonatomic, readwrite) NSInteger code;
@property (nonatomic, strong)  NSString *userId;
@property (nonatomic, strong) id<PinEngineDelegate> delegate;
@property (nonatomic, strong) NSMutableData *m_cReceivedData;

-(void)checkPinTimeOutSession;
-(void)checkLoginSessionOfUser;


@end
