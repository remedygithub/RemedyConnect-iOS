//
//  MenuViewController.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.07..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "MenuViewController.h"
#import "Logic.h"
#import "Skin.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

Logic *logic;
NSArray *menuItems;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Skin applySubMenuBGOnView:_menuTableView];
    [Skin applySubLogoOnImageView:_menuHeaderImageView];
    [_menuHeaderImageView setContentMode:UIViewContentModeScaleAspectFit];
    logic = [Logic sharedLogic];
    menuItems = [logic getDataToDisplayForSubMenu];
    [self setTitle:logic.title];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (nil == parent) {
        [logic unwindBackStack];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.textLabel setText:[[menuItems objectAtIndex:indexPath.row] objectForKey:@"name"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [logic setSubMenuDelegate:self];
    [logic handleActionWithTag:indexPath.row shouldProceedToPage:FALSE];
}

@end
