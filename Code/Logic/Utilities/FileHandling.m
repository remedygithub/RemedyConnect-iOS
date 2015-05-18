//
//  FileHandling.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.03..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "FileHandling.h"
#import <zipzap/zipzap.h>
#import <Foundation/Foundation.h>
#import "SSZipArchive.h"


@implementation FileHandling

+(NSString *)getDocumentsPath:(BOOL)temp
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                               objectAtIndex:0];
    if (!temp)
    {
        return documentsPath;
    }
    else
    {
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
    
    NSURL *dirURL = [NSURL fileURLWithPath:dataPath];
    // Exclude the dir from the backup
    BOOL success = [dirURL setResourceValue:[NSNumber numberWithBool:YES]
                          forKey:NSURLIsExcludedFromBackupKey
                           error:&error];
    
}

+(void)prepareSkinDirectory:(BOOL)temp {
    [FileHandling prepareDirectory:@"skin" inTemp:temp];
}

+(void)prepareTempDirectory {
    [FileHandling prepareDirectory:@"temp" inTemp:NO];
}



+(NSString *)getSkinFilePathWithComponent:(NSString *)pathComponent inTemp:(BOOL)temp
{
    NSString *skinPath = [self getEffectiveSkinDirectory:temp];
    NSLog(@"%@",skinPath);
    skinPath = [skinPath stringByAppendingPathComponent:pathComponent];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:skinPath])
    {
        return skinPath;
    }
    return nil;
}




+(NSString *)getEffectiveSkinDirectory:(BOOL)temp
{
    //Documents/skin/ -Creates Skin
    NSString *dataPath = [[self getDocumentsPath:temp] stringByAppendingPathComponent:@"/skin"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        //Documents/skin/
        NSURL *directoryURL = [NSURL fileURLWithPath:dataPath];
        NSArray *keys = [NSArray arrayWithObjects: NSURLIsDirectoryKey, nil];
        
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                             enumeratorAtURL:directoryURL
                                             includingPropertiesForKeys:keys
                                             options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                      NSDirectoryEnumerationSkipsHiddenFiles)
                                             errorHandler:^(NSURL *url, NSError *error)
                                             {
                                                 return YES;
                                             }];
        //Documents/skin/DesignPack/
        for (NSURL *url in enumerator)
        {
            BOOL present = [self SaveFileToResourseFromUrl:[url absoluteString]];
            NSLog(@"%hhd",present);
            
            NSNumber *isDirectory = nil;
            [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
//            if ([isDirectory boolValue] &&
//                    [[NSFileManager defaultManager] fileExistsAtPath:[[url path] stringByAppendingPathComponent:@"logo.png"]])
//            {
//                return [url path];
//            }
        
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:[dataPath stringByAppendingPathComponent:@"logo.png"]])
        {
            return dataPath;
        }
    }

    return @"";
}



+(BOOL)SaveFileToResourseFromUrl:(NSString *)zipUrl
{
    //NSURL *url = [[NSURL alloc] initWithString:zipUrl];
    NSURL *url = [[NSURL alloc] initWithString:[zipUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",url);
    NSError *error = nil;
    NSData *data = [NSData  dataWithContentsOfURL:url options:0 error:&error];
    if (!error) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *zipPath = [path stringByAppendingPathComponent:@"zipfile.zip"];
        NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
        
        [data writeToFile:zipPath options:0 error:&error];
        
        if(!error)
        {
            // TODO: Unzip
            [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
            NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzipPath error:&error];
            NSLog(@"the array %@", directoryContents);
            return YES;
            
        }
        else
        {
            NSLog(@"Error saving file %@",error);
            return NO;
        }
    }
    else
    {
        NSLog(@"Error downloading zip file: %@", error);
        return NO;
    }
}


+(void)downloadAndUnzip : (NSString *)sURL_p : (NSString *)sFolderName_p tempValue:(BOOL)temp
{
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_async(q, ^{
        //Path info
        NSURL *url = [NSURL URLWithString:sURL_p];
        NSData *data = [NSData  dataWithContentsOfURL:url];
        NSString *fileName = [[url path] lastPathComponent];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [data writeToFile:filePath atomically:YES];
        dispatch_async(main, ^
                       
                       
                       {
                           //Write To
                           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                           NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                           NSString *dataPath = [[self getDocumentsPath:temp] stringByAppendingPathComponent:sFolderName_p];
                           
                           [SSZipArchive unzipFileAtPath:filePath toDestination:dataPath];
                           
                       });
    });
    
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
        
        ZZArchive *archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:zipPath] error:nil];
        
        for (ZZArchiveEntry* entry in archive.entries)
        {
            NSURL* targetPath = [path URLByAppendingPathComponent:entry.fileName];
            
            if (entry.fileMode & S_IFDIR)
            {
                // check if directory bit is set
                [fileManager createDirectoryAtURL:targetPath
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil];
            }
            else
            {
                // Some archives don't have a separate entry for each directory and just
                // include the directory's name in the filename. Make sure that directory exists
                // before writing a file into it.
                [fileManager createDirectoryAtURL:[targetPath URLByDeletingLastPathComponent]
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil];
                
               

                //[entry.newData writeToURL:targetPath atomically:NO];
               // [archive.contents writeToURL:targetPath atomically:NO];
                
                 [entry.fileName writeToFile:[NSString stringWithFormat:@"%@",targetPath] atomically:NO encoding:NSUTF8StringEncoding  error:nil];
            }
            // Exclude the unzipped files from the backups
            NSError *error = nil;
            [targetPath setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
        }
        
        // We are now done with the archive
        archive = nil;
    }
}
@end
