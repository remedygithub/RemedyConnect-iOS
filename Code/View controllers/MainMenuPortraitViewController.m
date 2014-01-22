//
//  MainMenuPortraitViewController.m
//  YourPractice
//
//  Created by Adamek Zoltán on 2014.01.22..
//  Copyright (c) 2014 NewPush LLC. All rights reserved.
//

#import "MainMenuPortraitViewController.h"
#import "MainMenuLandscapeViewController.h"
#import <UIKit/UIDevice.h>

@interface MainMenuPortraitViewController ()

@end

@implementation MainMenuPortraitViewController

@synthesize landscapeController;

- (void)awakeFromNib {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.navigationController.delegate = self;
}

// Method to handle orientation changes.
- (void)orientationChanged:(NSNotification *)notification
{
    [self swapControllersIfNeeded];
}

// Called when a new view is shown.
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    // May be coming back from another controller to find we're
    // showing the wrong controller for the orientation.
    [self swapControllersIfNeeded];
}

- (void)swapControllersIfNeeded {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    // Check that we're not showing the wrong controller for the orientation.
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        self.navigationController.visibleViewController == self)
    {
        // Orientation is landscape but the visible controller is this one,
        // which is the portrait one.
        // Create new instance of landscape controller from the storyboard.
        // Use a property to keep track of it because we need it for
        // the check in the else branch.
        self.landscapeController =
            [self.storyboard instantiateViewControllerWithIdentifier:@"MainMenuLandscape"];
        // TODO - Set the landscape controller's model from the model we have.
        // self.landscapeViewController.model = self.model;
        // Push the new controller rather than use a segue so that we can do it
        // without animation.
        [self.navigationController pushViewController:self.landscapeController
                                             animated:NO];
    }
    else if (UIDeviceOrientationPortrait == deviceOrientation &&
             self.navigationController.visibleViewController == self.landscapeController)
    {
        // Orientation is portrait but the visible controller is
        // the landscape controller. Pop the top controller, we
        // know the portrait controller, self, is the next one down.
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
