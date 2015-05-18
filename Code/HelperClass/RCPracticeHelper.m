//
//  RCPracticeHelper.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 30/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "RCPracticeHelper.h"
static RCPracticeHelper *sharedHelper = nil;

@implementation RCPracticeHelper

+(RCPracticeHelper *)SharedHelper
{
    if (sharedHelper ==  nil)
    {
        sharedHelper = [[RCPracticeHelper alloc]init];
    }
    return sharedHelper;
}


-(id)init
{
    self= [super init];
    if (self)
    {
    }
    return self;
}

-(NSString *)wrapHTMLBodyWithStyle:(NSString *)bodyText {
    NSURL *bundleURL = [[NSBundle mainBundle] resourceURL];
    NSString *cssLink = @"<link rel='stylesheet' href='style.css' type='text/css'/>";
    NSString *format = @"<html><head><base href='%@'/>%@</head><body>%@</body>";
    NSString *result = [[NSString alloc] initWithFormat: format, bundleURL, cssLink, bodyText];
    return result;
}
@end
