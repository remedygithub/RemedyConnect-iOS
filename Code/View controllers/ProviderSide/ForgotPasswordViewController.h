//
//  ForgotPasswordViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 07/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YourPracticeAppDelegate.h"
@interface ForgotPasswordViewController : UIViewController<UIWebViewDelegate>
{
    NSURLRequest *request;
    NSMutableData *receivedData;
}

@end
