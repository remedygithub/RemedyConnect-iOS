//
//  ExternalLinkViewController.h
//  YourPractice
//
//  Created by Kishan Ravindra on 17/03/16.
//  Copyright © 2016 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExternalLinkViewController : UIViewController<UIWebViewDelegate>
{
    NSURLRequest *request;
    NSMutableData *receivedData;
}
@property (strong, nonatomic) NSString* linkUrlString;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
