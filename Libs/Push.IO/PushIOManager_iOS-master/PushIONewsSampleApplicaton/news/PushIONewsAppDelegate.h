//
//  PushIONewsAppDelegate.h
//  news
//
//  Copyright (c) 2013 Push IO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PushIOManager/PushIOManager.h>

@interface PushIONewsAppDelegate : UIResponder <UIApplicationDelegate, PushIOManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
