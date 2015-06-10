//
//  RCPinEngine.m
//  YourPractice
//
//  Created by Ravindra Kishan on 08/06/15.
//  Copyright (c) 2015 NewPush LLC. All rights reserved.
//

#import "RCPinEngine.h"
static RCPinEngine *sharedEngine = nil;

@implementation RCPinEngine
+(RCPinEngine *)SharedWebEngine
{
    if (sharedEngine ==  nil)
    {
        sharedEngine = [[RCPinEngine alloc]init];
    }
    return sharedEngine;
}

-(id)init
{
    self=[super init];
    
    if (self)
    {
        self.m_cReceivedData = [[NSMutableData alloc] init];
    }
    return self;
}

//Checkinh PIN Timeout Session
-(void)checkPinTimeOutSession
{
    NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:@"responseToken"];
    NSString *practice = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPracticeId"];
    NSString *physican = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhysicanId"];
    NSLog(@"%@",physican);
    
    NSString *lUrlString = [NSString stringWithFormat:@"https://tsapitest.remedyconnect.com/api/Physician/GetPhysiciansPinTimeout?PracticeID=%@&PhysicianID=%@&apikey=%@&token=%@",practice,physican,apiKey,tokenKey];
    
    
    //     NSString *lUrlString = [NSString stringWithFormat:@"https://tsapitest.remedyconnect.com/api/Communication/GetUnreadCalls?PhysicianID=%@&apikey=%@&token=%@",physican,apiKey,tokenKey];
    
    NSLog(@"%@",lUrlString);
    NSURL *lURL = [NSURL URLWithString:[lUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"URL:%@", lURL);
    
    NSMutableURLRequest *lRequest = [[NSMutableURLRequest alloc] initWithURL:lURL];
    [lRequest setHTTPMethod:@"GET"];
    [lRequest setValue:[NSString stringWithFormat:@"basic %@",token] forHTTPHeaderField:@"Authorization"];
    NSURLConnection *lConnection = [[NSURLConnection alloc] initWithRequest:lRequest delegate:self];
    [lConnection start];
}


-(void)checkLoginSessionOfUser
{
    NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:@"responseToken"];
    NSString *practice = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPracticeId"];
    NSString *physican = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhysicanId"];
    NSLog(@"%@",physican);
    
    NSString *lUrlString = [NSString stringWithFormat:@"https://tsapitest.remedyconnect.com/api/Communication/GetUnreadCalls?PhysicianID=%@&apikey=%@&token=%@",physican,apiKey,tokenKey];
    
    NSLog(@"%@",lUrlString);
    NSURL *lURL = [NSURL URLWithString:[lUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"URL:%@", lURL);
    
    NSMutableURLRequest *lRequest = [[NSMutableURLRequest alloc] initWithURL:lURL];
    [lRequest setHTTPMethod:@"GET"];
    [lRequest setValue:[NSString stringWithFormat:@"basic %@",token] forHTTPHeaderField:@"Authorization"];
    NSURLConnection *lConnection = [[NSURLConnection alloc] initWithRequest:lRequest delegate:self];
    [lConnection start];
}


#pragma mark NSURLConnectionDelegate Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse setting Length to 0");
    [self.m_cReceivedData setLength:0];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.code = [httpResponse statusCode];
    NSLog(@"Response code:%ld",(long)self.code);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.m_cReceivedData appendData:data];
}


-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([[challenge protectionSpace] authenticationMethod] == NSURLAuthenticationMethodServerTrust) {
        
        [[challenge sender] useCredential:[NSURLCredential credentialForTrust:[[challenge protectionSpace] serverTrust]] forAuthenticationChallenge:challenge];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    connection = nil;
    
    NSString* buffStr = [[NSString alloc]initWithBytes:[self.m_cReceivedData bytes] length:[self.m_cReceivedData length] encoding:NSUTF8StringEncoding];//NSNonLossyASCIIStringEncoding];//[[NSString alloc]initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    if (nil != buffStr)
    {
        //        [m_cReceivedData appendString:buffStr];
        NSLog(@" Received data %@", buffStr);
        if ([buffStr isEqualToString:@""]) {
            
            if (self.delegate != nil) {
                if ([self.delegate respondsToSelector:@selector(connectionManagerDidReceiveResponse:)])
                {
                    [self.delegate PinManagerDidReceiveResponse:[NSDictionary dictionaryWithObjectsAndKeys:@"false",@"success", nil]];
                }
                return;
            }
            
        }
        NSError *error;
        NSDictionary *lJsonData = [NSJSONSerialization JSONObjectWithData:self.m_cReceivedData options:kNilOptions error:&error];
        // sending back the response to class
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(connectionManagerDidReceiveResponse:)]) {
                [self.delegate PinManagerDidReceiveResponse:lJsonData];
            }
        }
    }
    else {
        NSLog(@"Received data nil when converted to NSString");
    }
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (self.delegate != nil) {
        if([self.delegate respondsToSelector:@selector(connectionManagerDidFailWithError:)])
        {
            [self.delegate PinManagerDidFailWithError:error];
        }
    }
}

@end
