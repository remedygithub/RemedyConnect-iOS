//
//  GPItemListViewController.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.12..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPItemListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemListTableView;
@property (nonatomic, strong) NSMutableArray *tableItems;
@end
