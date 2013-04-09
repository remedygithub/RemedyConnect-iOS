//
//  GPRootViewController.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.08..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPRootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (nonatomic, readonly, strong) NSMutableArray *menuItems;
@end
