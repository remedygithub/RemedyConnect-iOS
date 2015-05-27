//
//  RCPracticeHelper.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 30/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPracticeHelper : NSObject
{
    
}
+(RCPracticeHelper *)SharedHelper;

@property (nonatomic,readwrite) BOOL fromAboutUs;
@property (nonatomic,readwrite) BOOL fromAppointment;
@property (nonatomic,readwrite) BOOL fromParentingInfo;




//BOOL for checking logout
@property (nonatomic, readwrite) BOOL isChangePractice;
@property (nonatomic, readwrite) BOOL isLogout;
@property (nonatomic, readwrite) BOOL isApplicationMode;



@property (nonatomic, readwrite) BOOL fromPatient;
@property (nonatomic, readwrite) BOOL fromProvider;


//Patient
@property (nonatomic, strong) NSString *buttonName;
@property (nonatomic, strong) NSString *nextFeedName;
@property (nonatomic, strong) NSString *ExternalLinkName;

//News

@property (nonatomic, strong) NSString *newsName;
@property (nonatomic, strong) NSString *newsFeedName;
@property (nonatomic, strong) NSString *externalFeedName;



//Pain
@property (nonatomic, strong)NSString *painName;
@property (nonatomic, strong)NSString *htmlPlainText;
@property (nonatomic, strong)NSString *newsHtmlText;
@property (nonatomic, strong) NSString *webString;

//Parenting
@property (nonatomic, strong)NSString *parentingName;
@property (nonatomic, strong)NSString *parentingPlainText;


-(NSString *)wrapHTMLBodyWithStyle:(NSString *)bodyText;
@end
