//
//  SearchURLGenerator.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "SearchURLGenerator.h"

@implementation SearchURLGenerator

+(NSString *)getSearchURLByName:(NSString *)practiceName withFeedRoot:(NSString *)feedRoot {
    return [NSString stringWithFormat:@"%@?search=%@", feedRoot, practiceName];
}

@end
