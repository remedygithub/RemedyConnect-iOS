//
//  SplashViewController.h
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.16..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Logic.h"

@interface SplashViewController : UIViewController <ShouldDownloadStartDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *splashImageView;

@end
