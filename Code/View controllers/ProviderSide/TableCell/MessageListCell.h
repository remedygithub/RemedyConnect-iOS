//
//  MessageListCell.h
//  YourPractice
//
//  Created by Ravindra Kishan on 08/06/15.
//  Copyright (c) 2015 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *fNameAndLName;
@property (strong, nonatomic) IBOutlet UILabel *descpLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *iConImage;
@property (strong, nonatomic) IBOutlet UIImageView *readImage;

@end
