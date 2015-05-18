//
//  MessageDetailsViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 23/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNGridMenu.h"
#import "Macros.h"
@interface MessageDetailsViewController : UIViewController<RNGridMenuDelegate>
{
    
}
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;

@property(strong, nonatomic)NSString *str1;
@property(strong, nonatomic)NSString *str2;

@property (strong, nonatomic) IBOutlet UILabel *practiceNameLabel;
@end
