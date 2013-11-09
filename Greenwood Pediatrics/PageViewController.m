//
//  PageViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "PageViewController.h"
#import "Logic.h"

@interface PageViewController ()

@end

@implementation PageViewController

Logic *logic;

- (void)viewDidLoad {
    [super viewDidLoad];
    logic = [Logic sharedLogic];
    
    NSDictionary *page = [logic getDataToDisplayForPage];
    NSString *title = [page objectForKey:@"title"];
    NSString *text = [page objectForKey:@"text"];
    [self setTitle:title];
    
    [_pageWebView setDelegate:self];
    
    if (nil != text) {
        NSURL *baseURL = [NSURL URLWithString:@""];
        [_pageWebView loadHTMLString:text baseURL:baseURL];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (nil == parent) {
        [logic unwindBackStack];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //NSString *title = [_pageWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //[self setTitle:title];
}

@end
