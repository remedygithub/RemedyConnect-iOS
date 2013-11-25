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
#import "PopoverView/PopoverView.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

Logic *logic;

- (void)viewDidLoad {
    logic = [Logic sharedLogic];
    [Skin applyMainMenuBGOnImageView:_backgroundImage];
    [Skin applyMainLogoOnImageView:_logoImageView];
    NSArray *menu = [logic getDataToDisplayForMainMenu];
    for (int i = 0; i < [_mainMenuButtons count]; ++i) {
        UIButton *button = [_mainMenuButtons objectAtIndex:i];
        NSString *title = [[menu objectAtIndex:i] objectForKey:@"name"];
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

- (IBAction)menuButtonPressed:(id)sender {
    CGPoint point = CGPointMake(_menuButton.frame.origin.x + _menuButton.frame.size.width / 2,
                                _menuButton.frame.origin.y + _menuButton.frame.size.height);
    [PopoverView showPopoverAtPoint:point
                             inView:self.view
                    withStringArray:[NSArray arrayWithObjects:@"Update Your Practice Info",
                                     @"Choose Your Practice", @"Terms and Conditions", @"About", nil]
                           delegate:self];
}

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    if (index == 0) {
        [logic setUpdateDownloadStarterDelegate:self];
        [logic handleActionWithTag:0 shouldProceedToPage:FALSE];
    }
    [popoverView dismiss:TRUE];
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

#pragma mark - HUD handling
- (void)hudWasHidden:(MBProgressHUD *)hud {
	[statusHUD removeFromSuperview];
	statusHUD = nil;
}

#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading {
    statusHUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [statusHUD setDelegate:self];
    [statusHUD setDimBackground:TRUE];
    [statusHUD setLabelText:@"Starting download..."];
}

- (void)switchToIndeterminate {
    [statusHUD setMode:MBProgressHUDModeIndeterminate];
}

- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status {
    [statusHUD setMode:MBProgressHUDModeDeterminate];
    [statusHUD setLabelText:
     [[NSString alloc] initWithFormat:@"Downloading %d/%d...",
      [status currentFileIndex] + 1,
      [status numberOfFilesToDownload]]];
}

- (void)updateProgress:(DownloadStatus *)status {
    if ([status expectedLength] > 0) {
        statusHUD.progress = [status currentLength] / (float)[status expectedLength];
    }
}

- (void)didFinish {
    [statusHUD setMode:MBProgressHUDModeText];
    [statusHUD setLabelText:@"Finished!"];
    [statusHUD hide:YES afterDelay:2];
    // We have to reload the data:
    [logic resetAfterUpdate];
    [self viewDidLoad];
}

- (void)hasFailed {
    [statusHUD setLabelText:@"Failed to download files.\nPlease try again later."];
    [statusHUD hide:YES afterDelay:2];
}


@end
