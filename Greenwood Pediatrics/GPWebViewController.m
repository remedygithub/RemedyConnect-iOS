//
//  GPWebViewController.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.12..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "GPWebViewController.h"

@interface GPWebViewController ()

@end

@implementation GPWebViewController
@synthesize webView;

- (void)viewDidLoad {
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:TRUE];
}

@end
