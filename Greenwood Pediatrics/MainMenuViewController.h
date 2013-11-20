//
//  MainMenuViewController.h
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Logic.h"

@interface MainMenuViewController : UIViewController <MainMenuDelegate>

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *mainMenuButtons;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

- (IBAction)buttonPressed:(id)sender;

@end
