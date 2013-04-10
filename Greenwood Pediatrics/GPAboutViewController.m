//
//  GPAboutViewController.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.10..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "GPAboutViewController.h"

@interface GPAboutViewController ()

@end

@implementation GPAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [self setTitle:@"About"];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:TRUE];
}

@end
