//
//  RCRegisterEngine.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 16/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <Foundation/Foundation.h>
//Delegate method for forgot passwords
@protocol registerWebDelegate <NSObject>
-(void)registerFinishedLoading:(NSDictionary*)pResultDict;
-(void)registerFailedLoading:(NSError *)error;
@end

@interface RCRegisterEngine : NSObject
{
    id<registerWebDelegate>delegate;
    
}
@property (nonatomic, strong) id<registerWebDelegate> delegate;


+(RCRegisterEngine *)sharedHelper;


//Method for sending forgotpassword request
-(void)sendRequestForRegister:(NSString *)praticeId  Physician:(NSString *)physicianId device:(NSString *)DeviceId;

@end
