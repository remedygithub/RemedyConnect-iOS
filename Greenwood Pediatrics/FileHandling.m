//
//  FileHandling.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.03..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "FileHandling.h"
#import <zipzap/zipzap.h>

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
    NSString *dataPath = [[self getDocumentsPath] stringByAppendingPathComponent:@"/skin"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error];
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                              withIntermediateDirectories:NO
                                               attributes:nil error:&error];
}

+(NSString *)getEffectiveSkinDirectory {
    NSString *dataPath = [[self getDocumentsPath] stringByAppendingPathComponent:@"/skin"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        NSURL *directoryURL = [NSURL fileURLWithPath:dataPath];
        NSArray *keys = [NSArray arrayWithObjects: NSURLIsDirectoryKey, nil];
        
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                             enumeratorAtURL:directoryURL
                                             includingPropertiesForKeys:keys
                                             options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                      NSDirectoryEnumerationSkipsHiddenFiles)
                                             errorHandler:^(NSURL *url, NSError *error) {
                                                 return YES;
                                             }];
        
        for (NSURL *url in enumerator) {
            NSNumber *isDirectory = nil;
            [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            
            if ([isDirectory boolValue]) {
                return [url path];
            }
        }
    }
    return @"";
}

+(NSString *)getSkinFilePathWithComponent:(NSString *)pathComponent {
	NSString *skinPath = [self getEffectiveSkinDirectory];
    skinPath = [skinPath stringByAppendingPathComponent:pathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:skinPath]) {
        return skinPath;
    }
	return nil;
}

+(void)unzipFileInPlace:(NSString *)zipPath {
    zipPath = [self getFilePathWithComponent:zipPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *path = [[NSURL fileURLWithPath:zipPath] URLByDeletingLastPathComponent];
    @autoreleasepool {
        ZZArchive* archive = [ZZArchive archiveWithContentsOfURL:[NSURL fileURLWithPath:zipPath]];
        for (ZZArchiveEntry* entry in archive.entries) {
            NSURL* targetPath = [path URLByAppendingPathComponent:entry.fileName];
            
            if (entry.fileMode & S_IFDIR) {
                // check if directory bit is set
                [fileManager createDirectoryAtURL:targetPath
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil];
            }
            else {
                // Some archives don't have a separate entry for each directory and just
                // include the directory's name in the filename. Make sure that directory exists
                // before writing a file into it.
                [fileManager createDirectoryAtURL:[targetPath URLByDeletingLastPathComponent]
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil];
                
                [entry.newData writeToURL:targetPath
                            atomically:NO];
            }
        }
        
        // We are now done with the archive
        archive = nil;
    }
}

@end
