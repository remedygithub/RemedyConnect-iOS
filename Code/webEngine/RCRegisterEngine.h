//
//  RCRegisterEngine.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 16/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macros.h"
@protocol registerWebDelegate <NSObject>
-(void)RegisterManagerDidReceiveResponse:(NSDictionary*)pResultDict;
-(void)RegisterManagerDidFailWithError:(NSError *)error;
@end

@interface RCRegisterEngine : NSObject
{
    id<registerWebDelegate>delegate;
    
}
@property (nonatomic, strong) id<registerWebDelegate> delegate;
@property (nonatomic, readwrite) NSInteger code;
@property (nonatomic, strong)  NSString *userId;
@property (nonatomic, strong) NSMutableData *m_cReceivedData;

+(RCRegisterEngine *)sharedHelper;

//Registering User for Notification
-(void)sendRequestForRegister:(NSString *)praticeId  Physician:(NSString *)physicianId device:(NSString *)DeviceId;
@end
