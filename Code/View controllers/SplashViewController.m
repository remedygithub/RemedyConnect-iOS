//
//  SplashViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.16..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "SplashViewController.h"
#import "Logic.h"
#import "Skin.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
NSTimer *timer;
Logic *logic;

-(void)viewDidLoad {
    logic = [Logic sharedLogic];
    [Skin applySplashOnImageView:_splashImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE
                                            withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                            target:self
                                            selector:@selector(startSegue)
                                            userInfo:nil
                                            repeats:NO];
}

- (void)startSegue {
    [timer invalidate];
    [logic setDownloadStartDelegate:self];
    [logic ifDataAvailableAdvanceToMain];
}

@end
