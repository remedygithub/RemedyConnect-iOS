//
//  UINavigationController+Orientation.m
//  YourPractice
//
//  Created by Adamek Zoltán on 2014.01.27..
//  Copyright (c) 2014 NewPush LLC. All rights reserved.
//

#import "UINavigationController+Orientation.h"

@implementation UINavigationController (Orientation)

- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
