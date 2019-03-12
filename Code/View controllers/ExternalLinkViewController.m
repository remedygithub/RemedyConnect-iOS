//
//  ExternalLinkViewController.m
//  YourPractice
//
//  Created by Kishan Ravindra on 17/03/16.
//  Copyright © 2016 NewPush LLC. All rights reserved.
//

#import "ExternalLinkViewController.h"

@interface ExternalLinkViewController ()

@end

@implementation ExternalLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@",self.linkUrlString);
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.linkUrlString]];
    NSLog(@"%@",request);
    [self.webView loadRequest:request];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (theConnection)
    {
        receivedData = [NSMutableData data];
    }
    else
    {
#pragma mark connection failed
        UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"Sorry! " message:@"Failed to load webpage!"  delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [connectFailMessage show];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    // need to do this every time this view appears so that the "home" link keeps working
    [self.webView loadRequest:request];
}


- (IBAction)backBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response

{
    //Sent when the connection has received sufficient data to construct the URL response for its request.
    [receivedData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //increments the connection
    [receivedData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // for successfull loading of connection
    connection=nil;
}


@end
