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


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    connection = nil;
    
    NSString* buffStr = [[NSString alloc]initWithBytes:[self.m_cReceivedData bytes] length:[self.m_cReceivedData length] encoding:NSUTF8StringEncoding];//NSNonLossyASCIIStringEncoding];//[[NSString alloc]initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    if (nil != buffStr) {
        //        [m_cReceivedData appendString:buffStr];
        NSLog(@" Received data %@", buffStr);
        
        NSError *error;
         NSDictionary * lJsonData = [NSJSONSerialization JSONObjectWithData:self.m_cReceivedData options:kNilOptions error:&error];
        // sending back the response to class
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(connectionManagerDidReceiveResponse:)]) {
                [self.delegate logoutFinishedLoading:(BOOL)lJsonData];
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
            [self.delegate logoutFailedLoading:error];
        }
    }
}



@end
