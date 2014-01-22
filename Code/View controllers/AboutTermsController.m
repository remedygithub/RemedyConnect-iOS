//
//  AboutTermsController.m
//  YourPractice
//
//  Created by Adamek Zoltán on 2014.01.22..
//  Copyright (c) 2014 NewPush LLC. All rights reserved.
//

#import "AboutTermsController.h"
#import "Skin.h"

@implementation AboutTermsController

@synthesize webTitle;
@synthesize webText;

- (void)viewDidLoad {
    [super viewDidLoad];
    [Skin applyPageBGOnWebView:_pageWebView inViewController:self];
 
    [self setTitle:webTitle];
    
    [_pageWebView setDelegate:self];
    
    if (nil != webText) {
        NSURL *baseURL = [NSURL URLWithString:@""];
        webText = [Skin wrapHTMLBodyWithStyle:webText];
        [_pageWebView loadHTMLString:webText baseURL:baseURL];
    }
}


@end
