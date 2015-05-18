//
//  MessageListViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 09/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageDetailsViewController.h"
#import "RCHelper.h"
@interface MessageListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    RCHelper *help;
}
@property (strong, nonatomic) IBOutlet UILabel *practiceNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *messageTableView;
@property (strong, nonatomic) NSMutableArray *dummyMsgArray;
@property (strong, nonatomic) NSMutableArray *dummyArray;
@end
