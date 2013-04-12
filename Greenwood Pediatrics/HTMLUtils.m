//
//  HTMLUtils.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.12..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "HTMLUtils.h"

@implementation HTMLUtils
+ (NSString *)HTMLFromArray:(NSArray *)items {
    NSMutableString *HTML = [[NSMutableString alloc] init];
    for (NSDictionary *itemData in items) {
        [HTML appendString:[NSString stringWithFormat:
                            @"<h2>%@</h2><article>%@</article>",
                            [itemData objectForKey:@"title"],
                            [itemData objectForKey:@"text"]]];
    }
    return [[NSString alloc] initWithString:HTML];
}
@end
