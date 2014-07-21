//
//  DefaultPracticeHandling.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "DefaultPracticeHandling.h"

@implementation DefaultPracticeHandling

+ (void)setFeedRoot:(NSString *)feedRoot {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:feedRoot forKey:@"feedRoot"];
    [defaults synchronize];
}

+ (NSString *)feedRoot {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [defaults objectForKey:@"feedRoot"];
    return result;
}

+ (void)setFileFeed:(NSString *)fileFeed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:fileFeed forKey:@"fileFeed"];
    [defaults synchronize];
}

+ (NSString *)fileFeed {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [defaults objectForKey:@"fileFeed"];
    return result;
}

+ (void)setDesignPackURL:(NSString *)designPackURL {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:designPackURL forKey:@"designPackURL"];
    [defaults synchronize];
}

+ (NSString *)designPackURL {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [defaults objectForKey:@"designPackURL"];
    return result;
}
@end
