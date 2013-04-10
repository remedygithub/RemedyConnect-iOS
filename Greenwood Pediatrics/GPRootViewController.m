//
//  GPRootViewController.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "GPRootViewController.h"
#import "GPDownloadViewController.h"
#import "GPAboutViewController.h"

@interface GPRootViewController ()

@end

@implementation GPRootViewController
@synthesize menuTableView;
@synthesize menuItems;

NSMutableDictionary *pathIndexToTitle;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        pathIndexToTitle = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    menuItems = [[NSMutableArray alloc] initWithObjects:@"Download database", @"About", nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [menuTableView deselectRowAtIndexPath:[menuTableView indexPathForSelectedRow] animated:FALSE];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Where we configure the cell in each row
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell... setting the text of our cell's label
    cell.textLabel.text = [menuItems objectAtIndex:indexPath.row];
    [pathIndexToTitle setObject:[menuItems objectAtIndex:indexPath.row] forKey:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here.
    
    if ([[pathIndexToTitle objectForKey:indexPath] isEqual: @"About"]) {
        GPAboutViewController *aboutController = [[GPAboutViewController alloc] initWithNibName:@"GPAboutViewController" bundle:nil];
        [self.navigationController pushViewController:aboutController animated:TRUE];
        [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
    }
    if ([[pathIndexToTitle objectForKey:indexPath] isEqual: @"Download database"]) {
        GPDownloadViewController *downloadController = [[GPDownloadViewController alloc] initWithNibName:@"GPDownloadViewController" bundle:nil];
        [self.navigationController pushViewController:downloadController animated:TRUE];
        [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
    }
    

}

@end
