//
//  PageViewController.h
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Logic.h"

@interface PageViewController : UIViewController<UIWebViewDelegate, PageDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *pageWebView;
- (IBAction)goHome:(id)sender;
@end
