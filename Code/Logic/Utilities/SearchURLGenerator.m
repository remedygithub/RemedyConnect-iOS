//
//  SearchURLGenerator.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "SearchURLGenerator.h"
#import "NSString+URLEncoding.h"

@implementation SearchURLGenerator

+(NSString *)getSearchURLByName:(NSString *)practiceName withFeedRoot:(NSString *)feedRoot {
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
    return [NSString stringWithFormat:@"%@?search=%@", feedRoot,
            [practiceName urlEncodeUsingEncoding:NSUTF8StringEncoding]];
}

+(NSString *)getSearchURLWithLatitude: (double)latitude withLongitude:(double)longitude withFeedRoot:(NSString *)feedRoot {
    return [NSString stringWithFormat:@"%@?lat=%f&lon=%f", feedRoot, latitude, longitude];
}
@end
