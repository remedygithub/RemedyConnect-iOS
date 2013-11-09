//
//  ArticleSetViewController.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "ArticleSetViewController.h"
#import "Logic.h"

@interface ArticleSetViewController ()

@end

@implementation ArticleSetViewController

Logic *logic;
NSArray *articleSetItems;

- (void)viewDidLoad
{
    [super viewDidLoad];
    logic = [Logic sharedLogic];
    [self setTitle:logic.title];
    articleSetItems = [logic getDataToDisplayForArticleSet:TRUE];
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
