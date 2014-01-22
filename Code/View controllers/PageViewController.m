//
//  PageViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "PageViewController.h"
#import "Logic.h"
#import "Skin.h"

@interface PageViewController ()

@end

@implementation PageViewController

Logic *logic;

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
    
    logic = [Logic sharedLogic];
    
    NSDictionary *page = [logic getDataToDisplayForPage];
    NSString *title = [page objectForKey:@"title"];
    NSString *text = [NSString stringWithFormat:@"%@ %@",
                      [Skin logoContentsForWebView],
                      [page objectForKey:@"text"]];
    [self setTitle:title];
    
    [_pageWebView setDelegate:self];
    
    if (nil != text) {
        NSURL *baseURL = [NSURL URLWithString:@""];
        text = [Skin wrapHTMLBodyWithStyle:text];
        [_pageWebView loadHTMLString:text baseURL:baseURL];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (nil == parent) {
        [logic unwindBackStack];
    }
}

- (IBAction)goHome:(id)sender {
    [logic setPageDelegate:self];
    [logic moveBackToMain];
}

@end
