//
//  mainParser.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.07.05..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mainParser : NSObject
- (id)initWithXML:(NSString *)path;
- (Boolean)isRoot;
- (Boolean)isPage;
- (Boolean)isMenu;
- (Boolean)isArticleSet;
- (NSDictionary*)getPage;
- (NSArray*)getMenu;
- (NSArray*)getArticleSet;
- (NSArray*)getArticleSetTitles;
- (NSString*)getArticleFromSet:(NSUInteger)index;
- (NSArray*)getSubFeedURLs;
+ (NSString*)subFeedURLToLocal:(NSString*)subFeedURL;
- (NSArray*)getRootPractices;
@end
