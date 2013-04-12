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
#import "GPWebViewController.h"
#import "GPItemListViewController.h"
#import "parserPracticeNews.h"
#import "JJGWebView.h"
#import "Downloader.h"
#import "FileHandling.h"
#import "HTMLUtils.h"

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
    menuItems = [[NSMutableArray alloc] initWithObjects:
                 @"Is Your Child Sick?",
                 @"Office Info",
                 @"Office Location / Hours",
                 @"Practice News",
                 @"Page My Doctor",	
                 @"Download database",
                 @"About", nil];
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
    [menuTableView deselectRowAtIndexPath:[menuTableView indexPathForSelectedRow] animated:FALSE];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self shouldPopupDownload]) {
        GPDownloadViewController *downloadController = [[GPDownloadViewController alloc] initWithNibName:@"GPDownloadViewController" bundle:nil];
        [self.navigationController pushViewController:downloadController animated:TRUE];
    }
}

- (BOOL)shouldPopupDownload {
    Downloader *downloader = [[Downloader alloc] init];
    NSArray *filesToCheck = [NSArray arrayWithObjects:[FileHandling getFilePathWithComponent:@"iycs.xml"], nil];
    return [downloader isDownloadingNecessary:filesToCheck];
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
    // Let's control our table view menu here.
    if ([[pathIndexToTitle objectForKey:indexPath] isEqual: @"About"]) {
        GPAboutViewController *aboutController = [[GPAboutViewController alloc] initWithNibName:@"GPAboutViewController" bundle:nil];
        [self.navigationController pushViewController:aboutController animated:TRUE];
    }
    if ([[pathIndexToTitle objectForKey:indexPath] isEqual: @"Download database"]) {
        GPDownloadViewController *downloadController = [[GPDownloadViewController alloc] initWithNibName:@"GPDownloadViewController" bundle:nil];
        [self.navigationController pushViewController:downloadController animated:TRUE];
    }
    if ([[pathIndexToTitle objectForKey:indexPath] isEqual: @"Practice News"]) {
        JJGWebView *practiceNewsController = [[JJGWebView alloc] initWithNibName:@"JJGWebView" bundle:nil];
        [self.navigationController pushViewController:practiceNewsController animated:TRUE];
        parserPracticeNews *newsParser = [[parserPracticeNews alloc] init];
        practiceNewsController.title = @"Practice News";
        
        [practiceNewsController.webView loadHTMLString:[HTMLUtils HTMLFromArray:[newsParser getNews]]
                                               baseURL:[NSURL URLWithString:@"localhost"]];
    }
    if ([[pathIndexToTitle objectForKey:indexPath] isEqual: @"Page My Doctor"]) {
        NSURL *pageMyDoctorURL = [NSURL URLWithString:@"http://greenwood.pagemydoctor.net"];
        JJGWebView *webView = [[JJGWebView alloc] initWithNibName:@"JJGWebView" bundle:nil];
        webView.title = @"Page My Doctor";
        webView.webViewURL = pageMyDoctorURL;
        [self.navigationController pushViewController:webView animated:TRUE];
    }    
}

- (void)viewWillDisappear:(BOOL)animated {
    [menuTableView deselectRowAtIndexPath:[menuTableView indexPathForSelectedRow] animated:FALSE];
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
}

@end
