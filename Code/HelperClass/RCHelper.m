//
//  RCHelper.m
//  demoROC
//
//  Created by Ravindra Kishan on 29/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "RCHelper.h"
#import "Macros.h"
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




#pragma user setting and getting
-(NSMutableDictionary *)getUser:(NSString *)userName
{
    NSMutableArray *userArray = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDetails];
    if (userArray) {
        for (NSMutableDictionary *userDict in userArray) {
            if ([[userDict valueForKey:kUserName] isEqualToString:userName]) {
                return userDict;
            }
        }
        return nil;
    }
    else
        return nil;
}

-(NSMutableDictionary *)getLoggedInUser
{
    NSMutableArray *userArray = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDetails];
    if (userArray) {
        for (NSMutableDictionary *userDict in userArray) {
            if ([[userDict valueForKey:kLoggedIn] boolValue]) {
                return userDict;
            }
        }
        return nil;
    }
    else
        return nil;
}



-(NSMutableDictionary *) setUserWithUserName:(NSString *)userName andPin:(NSString *)pin andLoggedIN:(BOOL)isLoggedIn
{
    
    if (!pin) {
        pin = @"";
    }
    NSMutableArray *userArray = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDetails];
    // if array exist
    if (userArray) {
        NSMutableArray *userArrayMutable = [[NSMutableArray alloc] initWithArray:(NSArray *)userArray];
        for (int i = 0; i<userArrayMutable.count; i++) {
            NSMutableDictionary *dict = [[userArrayMutable objectAtIndex:i] mutableCopy];
            // if userName already exist, we are replacing the user in the array
            if ([[dict valueForKey:kUserName] isEqualToString:userName]) {
                NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userName,kUserName, pin,kSecretPin, [NSNumber numberWithBool:isLoggedIn], kLoggedIn, nil];
                [userArrayMutable replaceObjectAtIndex:i withObject:userDict];
                
                [[NSUserDefaults standardUserDefaults] setObject:userArrayMutable forKey:kUserDetails];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return userDict;
            }
            
        }
        //if username doesnt exist we are creating a new user and adding to array
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userName,kUserName, pin,kSecretPin, [NSNumber numberWithBool:isLoggedIn], kLoggedIn, nil];
        [userArrayMutable addObject:userDict];
        [[NSUserDefaults standardUserDefaults] setObject:userArrayMutable forKey:kUserDetails];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return userDict;
        
    }
    else //array doesent exist ; we are creating an array and adding the user into it and saving it
    {
    
        NSMutableArray *newUserArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setObject:userName forKey:kUserName];
        [userDict setObject:pin forKey:kSecretPin];
        [userDict setObject:[NSNumber numberWithBool:isLoggedIn] forKey:kLoggedIn];

        
        [newUserArray addObject:userDict];
        [[NSUserDefaults standardUserDefaults] setObject:newUserArray forKey:kUserDetails];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return userDict;
    }
}

-(void)removeAllUsersPinAndLogoff
{
    NSMutableArray *userArray = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDetails];
    if (userArray) {
        for (NSMutableDictionary *userDict in userArray) {
            [self setUserWithUserName:[userDict valueForKey:kUserName] andPin:nil andLoggedIN:NO];
    }
    }
}
@end
