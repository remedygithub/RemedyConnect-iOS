//
//  RCSessionEngine.m
//  YourPractice
//
//  Created by Ravindra Kishan on 22/05/15.
//  Copyright (c) 2015 NewPush LLC. All rights reserved.
//

#import "RCSessionEngine.h"
static RCSessionEngine *sharedEngine = nil;

@implementation RCSessionEngine


+(RCSessionEngine *)SharedWebEngine
{
    if (sharedEngine ==  nil)
    {
        sharedEngine = [[RCSessionEngine alloc]init];
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


//-(void)getLoginInTimeOutDetails
//{
//    NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:@"responseToken"];
//    NSString *practice = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPracticeId"];
//    NSLog(@"%@",token);
//    
//    NSString *lUrlString = [NSString stringWithFormat:@"https://tsapitest.remedyconnect.com/api/Physician/GetPracticeTimeout?PracticeID=%@&apikey=%@&token=%@",practice,apiKey,tokenKey];
//    NSLog(@"%@",lUrlString);
//    NSURL *lURL = [NSURL URLWithString:[lUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
//    NSLog(@"URL:%@", lURL);
//    
//    NSMutableURLRequest *lRequest = [[NSMutableURLRequest alloc] initWithURL:lURL];
//    [lRequest setHTTPMethod:@"GET"];
//    [lRequest setValue:[NSString stringWithFormat:@"basic %@",token] forHTTPHeaderField:@"Authorization"];
//    NSURLConnection *lConnection = [[NSURLConnection alloc] initWithRequest:lRequest delegate:self];
//    [lConnection start];
//}


-(void)LogoutTheUser
{
    NSString *userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"user"];
    NSLog(@"%@",userName);
    NSString *lUrlString = [NSString stringWithFormat:@"https://tsapitest.remedyconnect.com/api/Users/Logout?UserName=%@",userName];
    NSLog(@"%@",lUrlString);
    NSURL *lURL = [NSURL URLWithString:[lUrlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"URL:%@", lURL);
    NSMutableURLRequest *lRequest = [[NSMutableURLRequest alloc] initWithURL:lURL];
    [lRequest setHTTPMethod:@"POST"];
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
        NSLog(@" Received data %@", buffStr);
        
        if ([buffStr isEqualToString:@"true"]) {
            
            if (self.delegate != nil) {
                if ([self.delegate respondsToSelector:@selector(connectionManagerDidReceiveResponse:)]) {
                    [self.delegate SessionManagerDidReceiveResponse:[NSDictionary dictionaryWithObjectsAndKeys:@"true",@"success", nil]];
                }
                return;
            }

        }
        
        NSError *error;
        NSDictionary *lJsonData = [NSJSONSerialization JSONObjectWithData:self.m_cReceivedData options:kNilOptions error:&error];
        // sending back the response to class
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(connectionManagerDidReceiveResponse:)]) {
                [self.delegate SessionManagerDidReceiveResponse:lJsonData];
            }
        }
    }
    else
    {
        NSLog(@"Received data nil when converted to NSString");
    }
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (self.delegate != nil) {
        if([self.delegate respondsToSelector:@selector(connectionManagerDidFailWithError:)])
        {
            [self.delegate SessionManagerDidFailWithError:error];
        }
    }
}

@end
