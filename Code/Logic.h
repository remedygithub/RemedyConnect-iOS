//
//  Logic.h
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.07..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloader.h"
#import "DownloadStatus.h"
#import <CoreLocation/CoreLocation.h>
#import "FileHandling.h"
#import "RCHelper.h"
#import <UIKit/UIKit.h>

/*
 Logic is the central singleton for the application logic.
 */

@protocol DownloaderUIDelegate <NSObject>
- (void)hasStartedDownloading;
- (void)switchToIndeterminate;
- (void)didReceiveResponseForAFileSwitchToDeterminate:(DownloadStatus *)status;
- (void)updateProgress:(DownloadStatus *)status;
- (void)didFinish;
- (void)hasFailed;
@end

@protocol ShouldDownloadStartDelegate <NSObject>
@end

@protocol MainMenuDelegate <NSObject>
@end

@protocol SubMenuDelegate <NSObject>
@end

@protocol ArticleSetDelegate <NSObject>
@end

@protocol PageDelegate <NSObject>
@end

@protocol PracticeListDownloadStarterDelegate <DownloaderUIDelegate>
@end

@protocol MainDownloadStarterDelegate <DownloaderUIDelegate>
@end

@protocol UpdateDownloadStarterDelegate <DownloaderUIDelegate>
@end

@interface Logic : NSObject <DownloaderDelegate>
@property (nonatomic, strong) UIViewController <ShouldDownloadStartDelegate> *downloadStartDelegate;
@property (nonatomic, strong) UIViewController <PracticeListDownloadStarterDelegate> *practiceListDownloadStarterDelegate;
@property (nonatomic, strong) UIViewController <MainDownloadStarterDelegate> *mainDownloadStarterDelegate;
@property (nonatomic, strong) UIViewController <UpdateDownloadStarterDelegate> *updateDownloadStarterDelegate;
@property (nonatomic, strong) UIViewController <MainMenuDelegate> *mainMenuDelegate;
@property (nonatomic, strong) UIViewController <SubMenuDelegate> *subMenuDelegate;
@property (nonatomic, strong) UIViewController <ArticleSetDelegate> *articleSetDelegate;
@property (nonatomic, strong) UIViewController <PageDelegate> *pageDelegate;
@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly) Boolean locationBasedSearch;
@property (nonatomic) Boolean canAdvanceToPracticeSelect;

+ (id)sharedLogic;

-(void)unwindBackStack;
-(void)resetBackStack;
-(void)unwind;

#pragma mark - Download-related methods
-(void)ifDataAvailableAdvanceToMain;
-(void)startDownloadingRootForPracticeSelectionByName:(NSString *)practiceName;
-(void)startDownloadingRootForPracticeSelectionByLocation:(CLLocation *)location;
-(void)resetAfterUpdate;
-(void)resetBeforeSelection;

#pragma mark - Practice list
-(NSArray *)getPracticeList;

#pragma mark - Getting response from menus etc.
/*
 This is done via using a tag, since at the main menu screen we break the menu
 into two, but they should be handled together logically.
 */
-(void)handleActionWithTag:(NSInteger)tag shouldProceedToPage:(Boolean)proceedToPage;

#pragma mark - Controlling the scenes
/*
 If we have the scene as a delegate, we can perform the segues in its place:
 */
-(void)advanceToPracticeSelection;
-(void)advanceToMainMenu;
-(void)advanceToSubMenu;
-(void)advanceToArticleSet;
-(void)advanceToPage;
-(void)moveBackToMain;

#pragma mark - Fetching data for the scenes
-(NSArray *)getDataToDisplayForMainMenu;
-(NSArray *)getDataToDisplayForSubMenu;
-(NSArray *)getDataToDisplayForArticleSet:(Boolean)titlesOnly;
-(NSDictionary *)getDataToDisplayForPage;

#pragma mark - About and Terms loading
-(NSString *)getAboutHTML;
-(NSString *)getTermsHTML;

@end
