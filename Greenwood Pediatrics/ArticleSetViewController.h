//
//  ArticleSetViewController.h
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Logic.h"

@interface ArticleSetViewController : UITableViewController <ArticleSetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;

@end
