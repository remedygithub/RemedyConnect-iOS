//
//  SelectPracticeTableViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.18..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "SelectPracticeTableViewController.h"
#import "SelectYourPracticeTableCell.h"

@interface SelectPracticeTableViewController ()

@end

@implementation SelectPracticeTableViewController

@synthesize practiceNames;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [practiceNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"practiceCell";
    SelectYourPracticeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    [cell.practiceName setText:[practiceNames objectAtIndex:indexPath.row]];
    
    return cell;
}


@end
