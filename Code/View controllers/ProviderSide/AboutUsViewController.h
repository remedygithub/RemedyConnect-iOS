//
//  AboutUsViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 10/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUsViewController : UIViewController<UIWebViewDelegate,UINavigationControllerDelegate>
{
    NSURLRequest *request;
    NSMutableData *receivedData;
}
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *Text;
@property (strong, nonatomic) NSString *Type;
@end
