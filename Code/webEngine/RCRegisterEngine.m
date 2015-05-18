//
//  RCRegisterEngine.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 16/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "RCRegisterEngine.h"
static RCRegisterEngine *sharedHelper = nil;


@implementation RCRegisterEngine
@synthesize delegate;

+(RCRegisterEngine *)sharedHelper
{
    if (sharedHelper == nil)
    {
        sharedHelper=[[RCRegisterEngine alloc]init];
    }
    return sharedHelper;
}

-(void)sendRequestForRegister:(NSString *)praticeId  Physician:(NSString *)physicianId device:(NSString *)DeviceId
{
    NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:@"responseToken"];
    NSLog(@"%@",token);
    NSString *lUrlString = [NSString stringWithFormat:@"https://tsapitest.remedyconnect.com/api/Communication/InsertPhysicianMobileDevice?PracticeID=%@&PhysicianID=%@&DeviceID=%@",praticeId,physicianId,DeviceId];
    NSLog(@"%@",lUrlString);
    
    //NSURL *lURL = [NSURL URLWithString:[lUrlString stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding]];
    
    NSURL *lURL = [NSURL URLWithString:[lUrlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSLog(@"URL: %@", lURL);
    
   // NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:lURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest  requestWithURL:lURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
    [urlRequest setHTTPMethod:@"GET"];
    //[urlRequest setValue:tokenRep forHTTPHeaderField:@"token"];
    NSLog(@"%@",[NSString stringWithFormat:@"basic %@",token]);
    [urlRequest setValue:[NSString stringWithFormat:@"basic%@",token] forHTTPHeaderField:@"Authorization"];

    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
         if ([httpResponse statusCode] == 200)
         {
             NSError *jsonParsingError = nil;
             NSMutableDictionary *pResultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
             if ([[pResultDict objectForKey:@"success"] boolValue] )
             {
                 
             }
             [self performSelectorOnMainThread:@selector(sendBackTheDelgate:) withObject:pResultDict waitUntilDone:YES];
         }
         else
         {
             if (self.delegate != nil) {
                 if ([self.delegate respondsToSelector:@selector(registerFailedLoading:)]) {
                     [self.delegate registerFailedLoading:error];
                 }
             }
         }
         
     }];
}

// sending the delegate back to the class from where it is called
-(void) sendBackTheDelgate:(id) data
{
    NSMutableDictionary *pResultDict = (NSMutableDictionary *)data;
    if (self.delegate != nil)
    {
        if ([self.delegate respondsToSelector:@selector(registerFinishedLoading:)]) {
            [self.delegate registerFinishedLoading:pResultDict];
        }
    }
}


@end
