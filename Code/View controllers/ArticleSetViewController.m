//
//  ArticleSetViewController.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "ArticleSetViewController.h"
#import "Logic.h"
#import "Skin.h"

@interface ArticleSetViewController ()

@end

@implementation ArticleSetViewController

Logic *logic;
NSArray *articleSetItems;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Skin applySubMenuBGOnView:_menuTableView];
    [Skin applySubLogoOnImageView:_headerImageView];
    [_headerImageView setContentMode:UIViewContentModeScaleAspectFit];
    logic = [Logic sharedLogic];
    [self setTitle:logic.title];
    articleSetItems = [logic getDataToDisplayForArticleSet:TRUE];
    [self displayImages];

}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (nil == parent)
    {
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
                       self.headerImageView.image = img;
                   });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [articleSetItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.textLabel setText:[articleSetItems objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [logic setArticleSetDelegate:self];
    [logic handleActionWithTag:indexPath.row shouldProceedToPage:TRUE];
}

@end
