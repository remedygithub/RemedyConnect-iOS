//
//  FileHandling.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.03..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "FileHandling.h"

@implementation FileHandling
+ (NSString *)getFilePathWithComponent:(NSString *)pathComponent {
	NSArray *path =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[path objectAtIndex:0] stringByAppendingPathComponent:pathComponent];
}

+(NSString *)IYCScategoryIDtoFileName:(NSString *)categoryID {
    NSMutableString *fileName =
    [[NSMutableString alloc]
     initWithFormat:@"%@%@.xml",
     [FileHandling getFilePathWithComponent:@"iycs-"],
     categoryID];
    return [[NSString alloc] initWithString:fileName];
}
@end
