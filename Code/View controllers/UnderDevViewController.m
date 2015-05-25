//
//  UnderDevViewController.m
//  YourPractice
//
//  Created by Ravindra Kishan on 21/05/15.
//  Copyright (c) 2015 NewPush LLC. All rights reserved.
//

#import "UnderDevViewController.h"

@interface UnderDevViewController ()

@end

@implementation UnderDevViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:nil message:@"PIN has been set successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backBtnTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
