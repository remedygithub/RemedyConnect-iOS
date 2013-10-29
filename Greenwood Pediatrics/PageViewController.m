//
//  PageViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_pageWebView setDelegate:self];
     
    NSURL *URL = [NSURL URLWithString:@"http://zoltanadamek.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [_pageWebView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [_pageWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self setTitle:title];
}

@end
