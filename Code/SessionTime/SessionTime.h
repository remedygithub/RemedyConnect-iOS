//
//  SessionTime.h
//  RemedyConnect
//
//  Created by Ravindra Kishan on 13/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#define kApplicationTimeoutInMinutes 1
#define kApplicationDidTimeoutNotification @"ApplicationDidTimeout"

#define kApplicationLoginTimeoutInMinutes 360
#define kApplicationDidLoginTimeoutNotification @"ApplicationDidLoginTimeout"

@interface SessionTime : UIApplication
{
    NSTimer *idleTimer,*loginTimer;
}
- (void)resetIdleTimer;
@end
