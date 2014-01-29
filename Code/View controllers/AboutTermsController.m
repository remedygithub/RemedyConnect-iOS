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

- (void)awakeFromNib {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.navigationController.delegate = self;
    [self performSelector:@selector(reOrient) withObject:nil afterDelay: 0];
}

// Method to handle orientation changes.
- (void)orientationChanged:(NSNotification *)notification
{
    [self performSelector:@selector(reOrient) withObject:nil afterDelay: 0];
}

// Called when a new view is shown.
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    // May be coming back from another controller to find we're
    // showing the wrong controller for the orientation.
    [self performSelector:@selector(reOrient) withObject:nil afterDelay: 0];
}

- (void)reOrient {
    [Skin reorientBGFrameInViewController:self];
}

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

- (void)viewWillAppear:(BOOL)animated {
    [self reOrient];
}


@end
