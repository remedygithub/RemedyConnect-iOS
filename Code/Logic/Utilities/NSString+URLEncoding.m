//
//  NSString+URLEncoding.m
//  YourPractice
//
//  Created by Adamek Zoltán on 2014.03.10..
//  Copyright (c) 2014 NewPush LLC. All rights reserved.
//

#import "NSString+URLEncoding.h"

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                        NULL,
                                                        (CFStringRef)self,
                                                        NULL,
                                                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                        CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end