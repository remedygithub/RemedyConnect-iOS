//
//  mainParser.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.07.05..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface Parser : NSObject

- (id)initWithXML:(NSString *)path;
- (Boolean)isRoot;
- (Boolean)isFileFeed;
- (Boolean)isPage;
- (Boolean)isMenu;
- (Boolean)isArticleSet;
- (NSArray*)getRootPractices;
- (NSDictionary*)getPage;
- (NSArray*)getMenu;
- (NSArray*)getFileFeed;
- (NSArray*)getArticleSet;
- (NSArray*)getArticleSetTitles;
- (NSDictionary*)getArticleFromSet:(NSUInteger)index;
- (NSArray*)getSubFeedURLs;
- (NSArray*)getSubFeedURLsFromFileFeed;
+ (NSString*)subFeedURLToLocal:(NSString*)subFeedURL withFeedRoot:(NSString*)feedRoot inTemp:(BOOL)temp;

@end
