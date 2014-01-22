//
//  MainMenuPortraitViewController.h
//  YourPractice
//
//  Created by Adamek Zoltán on 2014.01.22..
//  Copyright (c) 2014 NewPush LLC. All rights reserved.
//

#import "MainMenuViewController.h"
#import "MainMenuLandscapeViewController.h"

@interface MainMenuPortraitViewController : MainMenuViewController <UINavigationControllerDelegate>

@property (nonatomic, weak) MainMenuLandscapeViewController *landscapeController;

@end
