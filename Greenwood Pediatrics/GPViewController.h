//
//  GPViewController.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.02..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface GPViewController : UIViewController <MBProgressHUDDelegate, NSURLConnectionDelegate>
{
    MBProgressHUD *statusHUD;
}
- (IBAction)startDownload:(id)sender;
@end
