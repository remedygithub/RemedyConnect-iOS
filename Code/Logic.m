//
//  Logic.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.07..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "Logic.h"
#import "SearchURLGenerator.h"
#import "FileHandling.h"
#import "DefaultPracticeHandling.h"
#import "Downloader.h"
#import "Parser.h"

@implementation Logic

@synthesize title = _title;

#pragma mark - Internal vars

Downloader *downloader;
NSArray *practiceList = nil;
NSMutableArray *feedStack = nil;

#pragma mark - Internal vars for article set content parsing

bool shouldParseNextAsArticleSet = FALSE;
int itemFromArticleSet = -1;

#pragma mark - Shared instance

+ (id)sharedLogic {
    static Logic *logic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logic = [[self alloc] init];
    });
    return logic;
}

#pragma mark - Initializer

- (id)init {
    if (self = [super init]) {
        feedStack = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

#pragma mark - Feed back stack handling
-(void)pushFeedToBackStack:(NSString *)feed {
    //NSLog(@"Pushed feed to stack: %@", feed);
    [feedStack addObject:feed];
}

-(NSString *)getCurrentFeedInStack {
    //NSLog(@"Reading stack");
    return [feedStack lastObject];
}

-(void)unwindBackStack {
    if ([feedStack count] > 0) {
        [feedStack removeLastObject];
        //NSLog(@"Unwinded stack");
    }
}

-(void)resetBackStack {
    NSMutableArray* newStack = [[NSMutableArray alloc] initWithCapacity:10];
    [newStack addObject:[feedStack objectAtIndex:0]];
    feedStack = newStack;
}

#pragma mark - Download-related methods

+(NSString *)getFeedRoot {
    return @"https://cms.pediatricweb.com/mobile-app";
}

-(void)ifDataAvailableAdvanceToMain {
    if (nil != [self downloadStartDelegate]) {
        if ([FileHandling doesIndexExists]) {
            [self pushFeedToBackStack:[DefaultPracticeHandling feedRoot]];
            [[self downloadStartDelegate] performSegueWithIdentifier:@"SkipToMainMenu"
                                                              sender:self];
            [self resetAllDelegates];
        }
        else {
            [[self downloadStartDelegate] performSegueWithIdentifier:@"ToPracticeSearch"
                                                              sender:self];
            [self resetAllDelegates];
        }
    }
}

-(void)startDownloadingRootForPracticeSelectionByName:(NSString *)practiceName {
    downloader = [[Downloader alloc] init];
    [downloader setDelegate:self];
    NSString *URL = [SearchURLGenerator getSearchURLByName:practiceName
                                              withFeedRoot:[Logic getFeedRoot]];
    [downloader addURLToDownload:URL
                          saveAs:[FileHandling getFilePathWithComponent:@"root.xml"]];
    [downloader startDownload];
}

-(void)startDownloadingRootForPracticeSelectionByLocation {
    
}

-(void)resetAfterUpdate {
    [self resetAllDelegates];
    [self resetBackStack];
}

-(void)resetBeforeSelection {
    [self resetAllDelegates];
    feedStack = [[NSMutableArray alloc] initWithCapacity:10];
}

#pragma mark - Practice list
-(NSArray *)getPracticeList {
    Parser *parser = [[Parser alloc] initWithXML:[FileHandling getFilePathWithComponent:@"root.xml"]];
    if ([parser isRoot]) {
        practiceList = [parser getRootPractices];
    }
    return practiceList;
}

#pragma mark - DownloaderDelegate
- (void)hasStartedDownloadingFirst {
    if (nil != [self practiceListDownloadStarterDelegate]) {
        [[self practiceListDownloadStarterDelegate] hasStartedDownloading];
    }
    if (nil != [self mainDownloadStarterDelegate]) {
        [[self mainDownloadStarterDelegate] hasStartedDownloading];
    }
    if (nil != [self updateDownloadStarterDelegate]) {
        [[self updateDownloadStarterDelegate] hasStartedDownloading];
    }
}

- (void)hasStartedDownloadingNext {
    if (nil != [self practiceListDownloadStarterDelegate]) {
        [[self practiceListDownloadStarterDelegate] switchToIndeterminate];
    }
    if (nil != [self mainDownloadStarterDelegate]) {
        [[self mainDownloadStarterDelegate] switchToIndeterminate];
    }
    if (nil != [self updateDownloadStarterDelegate]) {
        [[self updateDownloadStarterDelegate] switchToIndeterminate];
    }
}

- (void)didReceiveResponseForAFile {
    if (nil != [self practiceListDownloadStarterDelegate]) {
        [[self practiceListDownloadStarterDelegate] didReceiveResponseForAFileSwitchToDeterminate:[downloader status]];
    }
    if (nil != [self mainDownloadStarterDelegate]) {
        [[self mainDownloadStarterDelegate] didReceiveResponseForAFileSwitchToDeterminate:[downloader status]];
    }
    if (nil != [self updateDownloadStarterDelegate]) {
        [[self updateDownloadStarterDelegate] didReceiveResponseForAFileSwitchToDeterminate:[downloader status]];
    }
}

- (void)didReceiveDataForAFile {
    if (nil != [self practiceListDownloadStarterDelegate]) {
        [[self practiceListDownloadStarterDelegate] updateProgress:[downloader status]];
    }
    if (nil != [self mainDownloadStarterDelegate]) {
        [[self mainDownloadStarterDelegate] updateProgress:[downloader status]];
    }
    if (nil != [self updateDownloadStarterDelegate]) {
        [[self updateDownloadStarterDelegate] updateProgress:[downloader status]];
    }
}

- (void)didFinishForAFile {
    if (nil != [self mainDownloadStarterDelegate] ||
            nil != [self updateDownloadStarterDelegate]) {
        NSArray *files = [downloader filesToDownload];
        NSUInteger fileIndex = [[downloader status] currentFileIndex];
        NSString *filePath = [[files objectAtIndex:fileIndex] objectForKey:@"path"];
        Parser *parser = [[Parser alloc]
                          initWithXML:filePath];
        if ([filePath isEqualToString:[FileHandling getFilePathWithComponent:@"skin/DesignPack.zip"]]) {
            [FileHandling unzipFileInPlace:@"skin/DesignPack.zip"];
        }
        else if ([parser isMenu]) {
            NSArray *subFeedURLs = [parser getSubFeedURLs];
            for (NSString *URL in subFeedURLs) {
                // Have to do the following check, this might be empty because of externalLinks...
                if (![URL isEqualToString:@""]) {
                    [downloader addURLToDownload:URL
                                          saveAs:[Parser subFeedURLToLocal:URL withFeedRoot:[DefaultPracticeHandling feedRoot]]];
                }
            }
        }
    }
    
    if ([[downloader status] currentFileIndex] + 1 <
        [[downloader status] numberOfFilesToDownload]) {
        [downloader startNextDownload];
    }
    else {
        if (nil != [self practiceListDownloadStarterDelegate]) {
            [[self practiceListDownloadStarterDelegate] didFinish];
            [self advanceToPracticeSelection];
        }
        if (nil != [self mainDownloadStarterDelegate]) {
            [[self mainDownloadStarterDelegate] didFinish];
            [self advanceToMainMenu];
        }
        if (nil != [self updateDownloadStarterDelegate]) {
            [[self updateDownloadStarterDelegate] didFinish];
        }
    }
}

- (void)hasFailedToDownloadAFile {
    if (nil != [self practiceListDownloadStarterDelegate]) {
        [[self practiceListDownloadStarterDelegate] hasFailed];
    }
    if (nil != [self mainDownloadStarterDelegate]) {
        [[self mainDownloadStarterDelegate] hasFailed];
    }
    if (nil != [self updateDownloadStarterDelegate]) {
        [[self updateDownloadStarterDelegate] hasFailed];
    }
}

#pragma mark - Menu choices handling
-(void)handleActionWithTag:(NSInteger)tag shouldProceedToPage:(Boolean)proceedToPage {
    NSArray *menuItems;
    if (nil != _mainDownloadStarterDelegate) {
        [self startMainDownloadWithIndex:tag];
    }
    if (nil != _updateDownloadStarterDelegate) {
        [self startUpdateDownload];
    }
    if (nil != _mainMenuDelegate) {
        menuItems = [self getDataToDisplayForMainMenu];
        if ([menuItems count] >= tag) {
            NSDictionary *menuItem = [menuItems objectAtIndex:tag];
            _title = [menuItem objectForKey:@"name"];
            [self handleMenuItem:menuItem shouldProceedToPage:proceedToPage];
        }
        else {
            NSAssert(FALSE, @"Bad indexing");
        }
    }
    if (nil != _subMenuDelegate) {
        menuItems = [self getDataToDisplayForSubMenu];
        if ([menuItems count] >= tag) {
            NSDictionary *menuItem = [menuItems objectAtIndex:tag];
            _title = [menuItem objectForKey:@"name"];
            [self handleMenuItem:menuItem shouldProceedToPage:proceedToPage];
        }
        else {
            NSAssert(FALSE, @"Bad indexing");
        }
    }
    if (nil != _articleSetDelegate) {
        menuItems = [self getDataToDisplayForArticleSet:TRUE];
        if ([menuItems count] >= tag) {
            NSDictionary *menuItem = [menuItems objectAtIndex:tag];
            _title = [menuItems objectAtIndex:tag];
            itemFromArticleSet = tag;
            [self handleMenuItem:menuItem shouldProceedToPage:proceedToPage];
        }
        else {
            NSAssert(FALSE, @"Bad indexing");
        }
    }
}

-(void)startMainDownloadWithIndex:(NSInteger)index {
    NSString *feedURL = [[practiceList objectAtIndex:index] objectForKey:@"feed"];
    NSString *designPackURL = [[practiceList objectAtIndex:index] objectForKey:@"designPack"];
    [FileHandling emptySandbox];
    [FileHandling prepareSkinDirectory];
    [DefaultPracticeHandling setFeedRoot:feedURL];
    [DefaultPracticeHandling setDesignPackURL:designPackURL];
    downloader = [[Downloader alloc] init];
    [downloader setDelegate:self];
    [downloader addURLToDownload:feedURL
                          saveAs:[FileHandling getFilePathWithComponent:@"index.xml"]];
    [downloader addURLToDownload:designPackURL
                          saveAs:[FileHandling getFilePathWithComponent:@"skin/DesignPack.zip"]];
    [downloader startDownload];
}

-(void)startUpdateDownload {
    NSString *feedURL = [DefaultPracticeHandling feedRoot];
    NSString *designPackURL = [DefaultPracticeHandling designPackURL];
    [FileHandling emptySandbox];
    [FileHandling prepareSkinDirectory];
    downloader = [[Downloader alloc] init];
    [downloader setDelegate:self];
    [downloader addURLToDownload:feedURL
                          saveAs:[FileHandling getFilePathWithComponent:@"index.xml"]];
    [downloader addURLToDownload:designPackURL
                          saveAs:[FileHandling getFilePathWithComponent:@"skin/DesignPack.zip"]];
    [downloader startDownload];
}

-(void)handleMenuItem:(NSDictionary *)menuItem shouldProceedToPage:(Boolean)proceedToPage {
    NSString *feed, *externalLink;
    if (!proceedToPage && menuItem != nil) {
        feed = [menuItem objectForKey:@"feed"];
        externalLink = [menuItem objectForKey:@"externalLink"];
    }
    if (nil != feed && ![feed isEqualToString:@""]) {
        // We hit a feed link that we have to parse and control the transition
        // accordingly: we don't know whether it's a page, an articleset or a
        // sub-menu - yet.
        NSString *localFeed = [Parser subFeedURLToLocal:feed
                                           withFeedRoot:[DefaultPracticeHandling feedRoot]];
        Parser *parser = [[Parser alloc] initWithXML:localFeed];
        if ([parser isMenu]) {
            [self pushFeedToBackStack:feed];
            [self advanceToSubMenu];
        }
        if ([parser isArticleSet]) {
            [self pushFeedToBackStack:feed];
            if (proceedToPage) {
                shouldParseNextAsArticleSet = TRUE;
                [self advanceToPage];
            }
            else {
                [self advanceToArticleSet];
            }
        }
        if ([parser isPage]) {
            [self pushFeedToBackStack:feed];
            [self advanceToPage];
        }
    }
    // For external links, we should fire the default browser, remember
    // MainViewController.FireBrowser from the Android version:
    if (nil != externalLink && ![externalLink isEqualToString:@""]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:externalLink]];
    }
    // For articleset pages
    if (nil == feed && proceedToPage) {
        shouldParseNextAsArticleSet = TRUE;
        [self advanceToPage];
    }
}

-(void)resetAllDelegates {
    _downloadStartDelegate = nil;
    _practiceListDownloadStarterDelegate = nil;
    _mainDownloadStarterDelegate = nil;
    _updateDownloadStarterDelegate = nil;
    _mainMenuDelegate = nil;
    _subMenuDelegate = nil;
    _articleSetDelegate = nil;
    _pageDelegate = nil;
}

-(UIViewController *)getSeguePerformer {
    if (nil != _downloadStartDelegate) return _downloadStartDelegate;
    if (nil != _practiceListDownloadStarterDelegate) return _practiceListDownloadStarterDelegate;
    if (nil != _mainDownloadStarterDelegate) return _mainDownloadStarterDelegate;
    if (nil != _updateDownloadStarterDelegate) return _updateDownloadStarterDelegate;
    if (nil != _mainMenuDelegate) return _mainMenuDelegate;
    if (nil != _subMenuDelegate) return _subMenuDelegate;
    if (nil != _articleSetDelegate) return _articleSetDelegate;
    if (nil != _pageDelegate) return _pageDelegate;
    
    return nil;
}

-(void)advanceToPracticeSelection {
    [[self getSeguePerformer] performSegueWithIdentifier:@"ToPracticeSelect" sender:self];
    [self resetAllDelegates];
}

-(void)advanceToMainMenu {
    [self pushFeedToBackStack:[DefaultPracticeHandling feedRoot]];
    [[self getSeguePerformer] performSegueWithIdentifier:@"ToMainMenu" sender:self];
    [self resetAllDelegates];
}

-(void)advanceToSubMenu {
    if ([self getSeguePerformer] == _subMenuDelegate) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle: nil];
        UIViewController *destination = [storyboard instantiateViewControllerWithIdentifier:@"SubMenuViewController"];
        [_subMenuDelegate.navigationController pushViewController:destination animated:YES];
    }
    else {
        [[self getSeguePerformer] performSegueWithIdentifier:@"ToSubMenu" sender:self];
    }
    [self resetAllDelegates];
}

-(void)advanceToArticleSet {
    [[self getSeguePerformer] performSegueWithIdentifier:@"ToArticleSet" sender:self];
    [self resetAllDelegates];
}

-(void)advanceToPage {
    [[self getSeguePerformer] performSegueWithIdentifier:@"ToPage" sender:self];
    [self resetAllDelegates];
}

-(void)moveBackToMain {
    [[self getSeguePerformer].navigationController popToRootViewControllerAnimated:YES];
    [self resetBackStack];
    [self resetAllDelegates];
}

-(NSArray *)getDataToDisplayForMainMenu {
    NSArray *menu;
    NSString *localIndexFeed = [FileHandling getFilePathWithComponent:@"index.xml"];
    Parser *parser = [[Parser alloc] initWithXML:localIndexFeed];
    // load menu items, feeds, external links
    if ([parser isMenu]) {
        menu = [parser getMenu];
        return menu;
    }
    return nil;
}

-(NSArray *)getDataToDisplayForSubMenu {
    NSArray *submenu;
    NSString *localFeed = [Parser subFeedURLToLocal:[self getCurrentFeedInStack]
                                       withFeedRoot:[DefaultPracticeHandling feedRoot]];
    Parser *parser = [[Parser alloc] initWithXML:localFeed];
    if ([parser isMenu]) {
        submenu = [parser getMenu];
        return submenu;
    }
    return nil;
}

-(NSArray *)getDataToDisplayForArticleSet:(Boolean)titlesOnly {
    NSArray *articleSet;
    NSString *localFeed = [Parser subFeedURLToLocal:[self getCurrentFeedInStack]
                                       withFeedRoot:[DefaultPracticeHandling feedRoot]];
    Parser *parser = [[Parser alloc] initWithXML:localFeed];
    if ([parser isArticleSet]) {
        if (titlesOnly) {
            articleSet = [parser getArticleSetTitles];
        }
        else {
            articleSet = [parser getArticleSet];
        }
        return articleSet;
    }
    return nil;
}

-(NSDictionary *)getDataToDisplayForPage {
    NSString *localFeed = [Parser subFeedURLToLocal:[self getCurrentFeedInStack]
                                       withFeedRoot:[DefaultPracticeHandling feedRoot]];
    Parser *parser = [[Parser alloc] initWithXML:localFeed];
    NSDictionary *page;
    if (shouldParseNextAsArticleSet) {
        // The page is displaying content from an article set.
        // We have to re-push the article set feed into the stack to avoid
        // issues with the back button...
        [self pushFeedToBackStack:[self getCurrentFeedInStack]];
        page = [parser getArticleFromSet:itemFromArticleSet];
        shouldParseNextAsArticleSet = FALSE;
    }
    else {
        if ([parser isPage]) {
            page = [parser getPage];
        }
    }
    return page;
}

@end
