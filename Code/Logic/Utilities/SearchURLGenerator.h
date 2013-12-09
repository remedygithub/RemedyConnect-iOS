//
//  SearchURLGenerator.h
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchURLGenerator : NSObject

#pragma mark - URL transformation routines for searching
+(NSString *)getSearchURLByName:(NSString *)practiceName withFeedRoot:(NSString *)feedRoot;
//+(NSString *)getSearchURLByLocation;

@end
