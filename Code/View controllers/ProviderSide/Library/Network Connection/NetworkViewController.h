//
//  NetworkViewController.h
//  DocDock
//
//  Created by Ravindra Kishan on 13/11/14.
//  Copyright (c) 2014 Ravindra Kishan. All rights reserved.
//

/*
 
 QWINIX TECHNOLOGIES PVT LTD
 Copyright © 2014 - All Rights reserved
 
 THIS SOURCE CODE IS PROVIDED "AS IS" WITH NO WARRANTIES OF ANY KIND,
 EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, NONINFRINGEMENT, OR ARISING FROM A COURSE OF DEALING,
 USAGE OR TRADE PRACTICE.
 
 THIS COPYRIGHT NOTICE MAY NOT BE REMOVED FROM THIS FILE.
 
 */

#import <UIKit/UIKit.h>
#import "Reachability.h"

//Source for checking internet connection
//https://github.com/pokeb/asi-http-request/blob/master/External/Reachability/Reachability.h
//Delegate methods for checking Internet Connection

@protocol NetworkDelegate <NSObject>

@end

@interface NetworkViewController : UIViewController
{
    
}

@property (nonatomic, strong) id<NetworkDelegate> delegate;

+(NetworkViewController *)SharedWebEngine;

//Method for checking
-(BOOL)NetworkConnectionCheck;

@end
