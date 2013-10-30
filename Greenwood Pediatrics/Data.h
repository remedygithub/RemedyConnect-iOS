//
//  Data.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.07.05..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const FEED_ROOT;

@interface Data : NSObject

+(void)saveFeedRoot:(NSString *)feedRoot;
+(NSString *)getFeedRoot;

@end
