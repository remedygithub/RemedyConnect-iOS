//
//  NetworkViewController.m
//  DocDock
//
//  Created by Ravindra Kishan on 13/11/14.
//  Copyright (c) 2014 Ravindra Kishan. All rights reserved.
//

#import "NetworkViewController.h"
static NetworkViewController *sharedEngine = nil;

@interface NetworkViewController ()

@end

@implementation NetworkViewController

+(NetworkViewController *)SharedWebEngine
{
    if (sharedEngine ==  nil)
    {
        sharedEngine = [[NetworkViewController alloc]init];
    }
    return sharedEngine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Internet Connection checking method
-(BOOL)NetworkConnectionCheck
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if (![reachability isReachable])
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Remedy Connect service not reachable" message:@"This app needs Internet connectivity to function. Please check network connectivity." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    return [reachability isReachable];
}

@end
