//
//  MainMenuViewController.h
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Logic.h"
#import "PopoverView.h"
#import "MBProgressHUD.h"

@interface MainMenuViewController : UIViewController <MainMenuDelegate, PopoverViewDelegate, MBProgressHUDDelegate, UpdateDownloadStarterDelegate>
{
    MBProgressHUD *statusHUD;
}

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *mainMenuButtons;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)menuButtonPressed:(id)sender;
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index;

#pragma mark - DownloaderUIDelegate
- (void)hasStartedDownloading;
- (void)switchToIndeterminate;
- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status;
- (void)updateProgress:(DownloadStatus *)status;
- (void)didFinish;
- (void)hasFailed;

@end
