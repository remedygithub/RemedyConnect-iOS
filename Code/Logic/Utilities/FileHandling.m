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

+(NSString *)getDocumentsPath:(BOOL)temp {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                               objectAtIndex:0];
    if (!temp) {
        return documentsPath;
    }
    else {
        return [documentsPath stringByAppendingPathComponent:@"/temp"];
    }
}

+(NSString *)getFilePathWithComponent:(NSString *)pathComponent inTemp:(BOOL)temp {
	NSString *docPath = [self getDocumentsPath:temp];
	return [docPath stringByAppendingPathComponent:pathComponent];
}

+(Boolean)doesIndexExists:(BOOL)temp {
    NSString* documentsPath = [self getDocumentsPath:temp];
    NSString* rootFile = [documentsPath stringByAppendingPathComponent:@"index.xml"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:rootFile];
    return fileExists;
}

+(void)prepareDirectory:(NSString *)directoryName inTemp:(BOOL)temp {
    NSError *error;
    NSString *dataPath = [[self getDocumentsPath:temp]
                          stringByAppendingPathComponent:[@"/" stringByAppendingString:directoryName]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error];
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                              withIntermediateDirectories:NO
                                               attributes:nil error:&error];
}

+(void)prepareSkinDirectory:(BOOL)temp {
    [FileHandling prepareDirectory:@"skin" inTemp:temp];
}

+(void)prepareTempDirectory {
    [FileHandling prepareDirectory:@"temp" inTemp:NO];
}

+(NSString *)getEffectiveSkinDirectory:(BOOL)temp {
    NSString *dataPath = [[self getDocumentsPath:temp] stringByAppendingPathComponent:@"/skin"];
    
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
            
            if ([isDirectory boolValue] &&
                    [[NSFileManager defaultManager] fileExistsAtPath:[[url path] stringByAppendingPathComponent:@"logo.png"]]) {
                return [url path];
            }
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:[dataPath stringByAppendingPathComponent:@"logo.png"]]) {
            return dataPath;
        }
    }
    return @"";
}

+(NSString *)getSkinFilePathWithComponent:(NSString *)pathComponent inTemp:(BOOL)temp {
	NSString *skinPath = [self getEffectiveSkinDirectory:temp];
    skinPath = [skinPath stringByAppendingPathComponent:pathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:skinPath]) {
        return skinPath;
    }
	return nil;
}

+(void)emptySandbox:(BOOL)temp {
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (temp) {
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"/temp"];
    }
    NSMutableArray *files = [[NSMutableArray alloc] initWithArray:[fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]];
    [files removeObject:@"temp"];
    
    while (files.count > 0) {
        if (error == nil) {
            for (NSString *path in files) {
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                [fileMgr removeItemAtPath:fullPath error:&error];
            }
            files = [[NSMutableArray alloc] initWithArray:[fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]];
            [files removeObject:@"temp"];
        }
    }
}

+(void)unTempFiles {
    [FileHandling emptySandbox:NO];
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/temp"];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:tempDirectory error:&error];
    
    if (error == nil) {
        while (files.count > 0) {
            if (error == nil) {
                for (NSString *path in files) {
                    NSString *fromPath = [tempDirectory stringByAppendingPathComponent:path];
                    NSString *toPath = [documentsDirectory stringByAppendingPathComponent:path];
                    [fileMgr moveItemAtPath:fromPath toPath:toPath error:&error];
                    files = [fileMgr contentsOfDirectoryAtPath:tempDirectory error:&error];
                }
            }
        }
    }
}

+(void)unzipFileInPlace:(NSString *)zipPath inTemp:(BOOL)temp {
    zipPath = [self getFilePathWithComponent:zipPath inTemp:temp];
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
