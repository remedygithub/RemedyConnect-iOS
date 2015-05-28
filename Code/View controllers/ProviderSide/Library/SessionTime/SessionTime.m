//
//
//  SessionTime.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 13/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "SessionTime.h"

@implementation SessionTime

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    
    // Fire up the timer upon first event
    if(!idleTimer)
    {
        [self resetIdleTimer];
    }
    

    
    // Check to see if there was a touch event
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0) {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan)
        {
            [self resetIdleTimer];
        }
    }
}

- (void)resetIdleTimer
{
    if (idleTimer)
    {
        [idleTimer invalidate];
        idleTimer = nil;
    }

    int timeout = kApplicationTimeoutInMinutes * 60;
    idleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                   target:self
                                                 selector:@selector(idleTimerExceeded)
                                                 userInfo:nil
                                                  repeats:NO] ;
    
   /* int LoginTimeout = kApplicationLoginTimeoutInMinutes * 60;
    loginTimer = [NSTimer scheduledTimerWithTimeInterval:LoginTimeout
                                                 target:self
                                               selector:@selector(idleLoginTimerExceeded)
                                               userInfo:nil
                                                repeats:NO] ;*/
}

- (void)idleTimerExceeded
{
    /* Post a notification so anyone who subscribes to it can be notified when
     * the application times out */
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kApplicationDidTimeoutNotification object:nil];
}

/*-(void)idleLoginTimerExceeded
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kApplicationDidLoginTimeoutNotification object:nil];
}*/

@end
