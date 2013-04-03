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
@end
