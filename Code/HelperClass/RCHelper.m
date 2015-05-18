//
//  RCHelper.m
//  demoROC
//
//  Created by Ravindra Kishan on 29/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "RCHelper.h"
static RCHelper *sharedHelper = nil;
@implementation RCHelper

+(RCHelper *)SharedHelper
{
    if (sharedHelper ==  nil)
    {
        sharedHelper = [[RCHelper alloc]init];
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


-(NSString *)getSearchURLByName:(NSString *)practiceName
{
    practiceName = [practiceName stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceCharacterSet]];
    
    // Replace multiple spaces with a single one, just to make sure...
    NSError *error = nil;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:@" +"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    practiceName =
    [regex stringByReplacingMatchesInString:practiceName
                                    options:0
                                      range:NSMakeRange(0, [practiceName length])
                               withTemplate:@" "];
    NSLog(@"practicename = %@", practiceName);
    return [NSString stringWithFormat:@"search=%@",
            [practiceName urlEncodeUsingEncoding:NSUTF8StringEncoding]];
}


#pragma mark - About and Terms loading
-(NSString *)getAboutHTML {
    NSError* error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource: @"about" ofType: @"htm"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    return content;
}

-(NSString *)getTermsHTML {
    NSError* error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource: @"terms_and_conditions" ofType: @"htm"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    return content;
}

@end
