//
//  ForgotPasswordViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 07/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];

    //Settings for webview
    self.webView.opaque = NO;
    self.webView.clipsToBounds = YES;
    self.webView.scrollView.bounces = YES;
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(startActivity)];
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://admin.remedyoncall.com/Default.aspx?ReturnUrl=%2f"]];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection)
    {
        [self.webView loadRequest:request];
        receivedData = [NSMutableData data];
    }
    else
    {
        UIAlertView *connectFailMessage = [[UIAlertView alloc]initWithTitle:@"NSURLConnection " message:@"Failed in viewDidLoad"  delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [connectFailMessage show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    // need to do this every time this view appears so that the "home" link keeps working
    [self.webView loadRequest:request];
}

#pragma NSURLConnection Delegates
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
    //for successfull loading of connection
    connection=nil;
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopActivity)];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
