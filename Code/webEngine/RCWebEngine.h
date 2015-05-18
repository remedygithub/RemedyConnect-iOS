//
//  RCWebEngine.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 07/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define apiKey   @"SSB3aWxsIG1ha2UgbXkgQVBJIHNlY3VyZQ=="
#define tokenKey @"j2w+jHHs+F8fkvr7Vj5DlPuYg8VqXvOhbtaG4WaOqxA="
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
@end
