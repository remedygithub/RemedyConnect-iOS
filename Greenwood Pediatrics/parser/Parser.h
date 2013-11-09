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
- (Boolean)isPage;
- (Boolean)isMenu;
- (Boolean)isArticleSet;
- (NSArray*)getRootPractices;
- (NSDictionary*)getPage;
- (NSArray*)getMenu;
- (NSArray*)getArticleSet;
- (NSArray*)getArticleSetTitles;
- (NSDictionary*)getArticleFromSet:(NSUInteger)index;
- (NSArray*)getSubFeedURLs;
+ (NSString*)subFeedURLToLocal:(NSString*)subFeedURL withFeedRoot:(NSString*)feedRoot;

@end
