//
//  GPAppDelegate.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.02..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPRootViewController;

@interface GPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GPRootViewController *viewController;

@end
