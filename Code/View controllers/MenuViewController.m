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
#import "RCHelper.h"

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
    NSLog(@"%lu",(unsigned long)[menuItems count]);
    [self setTitle:logic.title];
    [self displayImages];
    [RCHelper SharedHelper].isBackFromArticle = YES;
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (nil == parent) {
        [logic unwindBackStack];
    }
}


-(void)displayImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    NSString *imageFilePath = [unzipPath stringByAppendingPathComponent:@"logo.png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
    UIImage *img = [UIImage imageWithData:imageData];
    
    NSString *tableBackFilePath = [unzipPath stringByAppendingPathComponent:@"background_main.png"];
    NSData *tableImgData = [NSData dataWithContentsOfFile:tableBackFilePath options:0 error:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:tableImgData]];
    [self.menuTableView setContentMode:UIViewContentModeCenter];
    self.menuTableView.backgroundView = imageView;
    
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       self.menuHeaderImageView.image = img;
                   });
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
