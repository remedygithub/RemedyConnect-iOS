//
//  AboutTermsController.h
//  YourPractice
//
//  Created by Adamek Zoltán on 2014.01.22..
//  Copyright (c) 2014 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface AboutTermsController : UIViewController<UIWebViewDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *pageWebView;
@property (weak, nonatomic) NSString *webTitle;
@property (weak, nonatomic) NSString *webText;
@end
