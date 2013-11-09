//
//  FileHandling.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.03..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "FileHandling.h"

@implementation FileHandling

+(NSString *)getDocumentsPath {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return documentsPath;
}

+(NSString *)getFilePathWithComponent:(NSString *)pathComponent {
	NSString *docPath = [self getDocumentsPath];
	return [docPath stringByAppendingPathComponent:pathComponent];
}

+(Boolean)doesIndexExists {
    NSString* documentsPath = [self getDocumentsPath];
    NSString* rootFile = [documentsPath stringByAppendingPathComponent:@"index.xml"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:rootFile];
    return fileExists;
}

+(void)prepareSkinDirectory {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/skin"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil error:&error];
}

@end
