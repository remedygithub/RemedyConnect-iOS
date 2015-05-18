//
//  ALActivityIndicatorView.h
//  iStadium
//
//  Created by Ravindra Kishan on 9/16/13.
//  Copyright (c) 2013 Ravindra Kishan. All rights reserved.
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

/*++++++++++++++++++++++++++++++++++++++//
Class to display a activity indicator on the views.
When a API request is sent, the activity indicator will appear on view (startAnimating).
When a response is recieved, the activity indicator will disappear from the view (stopAnimating).
//++++++++++++++++++++++++++++++++++++++*/

@interface ALActivityIndicatorView : UIView {
    
    UIActivityIndicatorView *m_cActivityIndicator;
}

@property (nonatomic, strong) UIActivityIndicatorView *m_cActivityIndicator;

- (void)startAnimating;
- (void)stopAnimating;
@end
