//
//  GPItemListViewController.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.12..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "GPItemListViewController.h"
#import "GPItemListWithHTMLCell.h"

@interface GPItemListViewController ()

@end

@implementation GPItemListViewController
@synthesize itemListTableView;
@synthesize tableItems;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    GPItemListWithHTMLCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GPItemListWithHTMLCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *itemData = [tableItems objectAtIndex:indexPath.row];
    cell.title.text = [itemData objectForKey:@"title"];
    [cell.webview loadHTMLString:[itemData objectForKey:@"text"]
                         baseURL:[NSURL URLWithString:@"localhost"]];
    [cell.title sizeToFit];
    [cell.webview sizeToFit];
    [cell sizeToFit];
    return cell;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:TRUE];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 260;
}

@end
