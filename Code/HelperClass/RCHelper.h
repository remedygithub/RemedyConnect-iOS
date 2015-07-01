//
//  RCHelper.h
//  demoROC
//
//  Created by Ravindra Kishan on 29/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+URLEncoding.h"
@interface RCHelper : NSObject
{
}
@property (nonatomic, strong) NSString *zipFile;
@property (nonatomic, readwrite) BOOL fromSelfSelect;
@property (nonatomic, readwrite) BOOL fromSelfSelectBack;
@property (nonatomic, readwrite) BOOL pinCreated;
@property (nonatomic, readwrite) BOOL fromLoginTimeout;
@property (nonatomic, readwrite) BOOL fromMenuReturn;
@property (nonatomic, readwrite) BOOL fromAgainList;
@property (nonatomic, readwrite) BOOL fromLocation;
@property (nonatomic, readwrite) BOOL menuToArticle;

//Alert Bool
@property (nonatomic, readwrite) BOOL isLogin;

//DetailTOlist
@property (nonatomic, readwrite) BOOL isFromDetailMessage;

//Passcode Bool
//@property (nonatomic, readwrite) BOOL isPassCodeView;
@property (nonatomic, readwrite) BOOL isCreateTimeOutRequest;

//Navigation Bool
@property (nonatomic, readwrite) BOOL isBackFromDetail;
@property (nonatomic, readwrite) BOOL isBackFromMessageList;


+(RCHelper *)SharedHelper;

//SearchPractice Data
@property (nonatomic, strong) NSString *addressData;
@property (nonatomic, strong) NSString *cityData;
@property (nonatomic, strong) NSString *officenameData;
@property (nonatomic, strong) NSString *stateData;
@property (nonatomic, strong) NSString *zipcodeData;
@property (nonatomic, strong) NSString *zipUrl;
@property (nonatomic, strong) NSString *practiceName;

//Login
@property (nonatomic, strong) NSString *PhysicianID;
@property (nonatomic, strong) NSString *practiceID;
@property (nonatomic, strong) NSString *tokenID;

//Practice Feeds
@property (nonatomic, strong) NSString *practiceFeed;

//Message Count
@property (nonatomic, strong) NSString *messageCount;

//User Registration for Message Notification
@property (nonatomic, strong) NSString *messageToken;


@property (nonatomic,strong) NSString *string1, *string2;

//Message List
@property (nonatomic, strong) NSString *messageFName;
@property (nonatomic, strong) NSString *messageLName;
@property (nonatomic, strong) NSString *messageDate;
@property (nonatomic, strong) NSString *messageDetails;
@property (nonatomic, strong) NSString *callerTypeID;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *urgentId;
@property (nonatomic, strong) NSString *callerId;
@property (nonatomic, strong) NSString *messageOpened;


//Instance Method
-(NSString *)getSearchURLByName:(NSString *)practiceName;
-(NSString *)getAboutHTML;
-(NSString *)getTermsHTML;

-(NSMutableDictionary *) setUserWithUserName:(NSString *)userName andPin:(NSString *)pin andLoggedIN:(BOOL)isLoggedIn;
-(NSMutableDictionary *)getLoggedInUser;
-(NSMutableDictionary *)getUser:(NSString *)userName;
@end
