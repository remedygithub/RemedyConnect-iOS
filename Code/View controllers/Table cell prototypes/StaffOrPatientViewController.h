//
//  StaffOrPatientViewController.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 31/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macros.h"
#import "RCHelper.h"
#import "RCPracticeHelper.h"
#import "Logic.h"
#import "ProviderLoginViewController.h"
#import "MainMenuViewController.h"
#import "RCSessionEngine.h"
#import "UnderDevViewController.h"
@interface StaffOrPatientViewController : UIViewController<SubMenuDelegate,MainMenuDelegate,SessionEngineDelegate>
{
    Logic *logic;
    NSString *practiceName;
}
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIButton *patientBtn;
@property (weak, nonatomic) IBOutlet UIButton *providerBtn;
@property (weak, nonatomic) IBOutlet UIButton *returnSearchLabel;
@property (weak, nonatomic) IBOutlet UILabel *amLabel;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) UIImageView *village;
@property (weak, nonatomic) UIImageView *backImage;


@end
