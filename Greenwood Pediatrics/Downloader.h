//
//  Downloader.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.04..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface Downloader : NSObject <NSURLConnectionDelegate>
- (void)addURLToDownloadAndSaveAs:(NSString *)URL saveAs:(NSString *)path;
@end
