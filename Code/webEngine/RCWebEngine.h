//
//  RCWebEngine.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 07/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import <Security/Security.h>

#define TestUrl     @"https://tsapitest.remedyconnect.com/api"
#define ProdUrl     @""
#define apiUrl TestUrl


//Delegate methods
@protocol WebEngineDelegate <NSObject>

-(void)connectionManagerDidReceiveResponse:(NSDictionary*)pResultDict;
-(void)connectionManagerDidFailWithError:(NSError *)error;

@end

@interface RCWebEngine : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
}

+(RCWebEngine *)SharedWebEngine;

@property (nonatomic, readwrite) NSInteger code;
@property (nonatomic, strong)  NSString *userId;
@property (nonatomic, strong) id<WebEngineDelegate> delegate;
@property (nonatomic, strong) NSMutableData *m_cReceivedData;

//Methods
-(void)userLogin:(NSString *)userName password:(NSString *)userPassword;
-(void)sendRequestForRegister:(NSString *)praticeId  Physician:(NSString *)physicianId device:(NSString *)DeviceId;
-(void)getLoginInTimeOutDetails;
-(void)checkUserUnreadMessages;
-(void)getMessageListInformation;
-(void)CheckMessageReadOrUnread;
@end
