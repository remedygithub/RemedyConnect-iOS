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
-(void)logoutFinishedLoading:(BOOL)pResultDict;
-(void)logoutFailedLoading:(NSError *)error;
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
-(void)LogoutTheUser;

@end
