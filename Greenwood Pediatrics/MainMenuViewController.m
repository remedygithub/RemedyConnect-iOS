//
//  MainMenuViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "MainMenuViewController.h"
#import "Logic.h"
#import "Skin.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

Logic *logic;

- (void)viewDidLoad {
    logic = [Logic sharedLogic];
    [Skin applyMainMenuBGOnImageView:_backgroundImage];
    NSArray *menu = [logic getDataToDisplayForMainMenu];
    for (int i = 0; i < [_mainMenuButtons count]; ++i) {
        UIButton *button = [_mainMenuButtons objectAtIndex:i];
        NSString *title = [[menu objectAtIndex:i] objectForKey:@"name"]; //feed, externalLink
        [button setTitle:title forState:UIControlStateNormal];
        [button setTag:i];
        [Skin applyBackgroundOnButton:button];
    }
}

- (IBAction)buttonPressed:(id)sender {
    [logic setMainMenuDelegate:self];
    for (UIButton *button in _mainMenuButtons) {
        if (sender == button) {
            [logic handleActionWithTag:[button tag] shouldProceedToPage:FALSE];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:TRUE];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:FALSE animated:TRUE];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:TRUE];
}

@end
