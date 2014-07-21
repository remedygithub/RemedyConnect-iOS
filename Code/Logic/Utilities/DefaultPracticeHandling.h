//
//  DefaultPracticeHandling.h
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultPracticeHandling : NSObject

#pragma mark - Store / retrieve the feed URLs for the currently selected practice
+ (void)setFeedRoot:(NSString *)feedRoot;
+ (NSString *)feedRoot;
+ (void)setFileFeed:(NSString *)fileFeed;
+ (NSString *)fileFeed;
+ (void)setDesignPackURL:(NSString *)designPackURL;
+ (NSString *)designPackURL;

@end
