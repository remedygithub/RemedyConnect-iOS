//
//  AboutUsViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 10/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
    
    NSLog(@"%@",self.Text);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
    NSString *imageFilePath = [unzipPath stringByAppendingPathComponent:@"background_main.png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
    UIImage *img = [UIImage imageWithData:imageData];
    
    UIImageView *yourImageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [yourImageView setImage:img];
    [yourImageView setContentMode:UIViewContentModeCenter];
    [self.view addSubview:yourImageView];
    
    [self.webView setDelegate:self];
    [self.webView setOpaque:NO];
    self.webView.layer.cornerRadius = 8;
    self.webView.opaque = NO;
    self.webView.clipsToBounds = YES;
    self.webView.scrollView.bounces = NO;
    [self.view bringSubviewToFront:self.webView];
    
    if ([self.Text isEqualToString:@"About"])
    {
      self.title = @"About Us";
      self.Type = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"htm" inDirectory:nil];
    }
    else
    {
        self.title = @"Terms and Conditions";

        self.Type = [[NSBundle mainBundle] pathForResource:@"terms_and_conditions" ofType:@"htm" inDirectory:nil];
    }
    request = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:self.Type]];
    [self.webView loadRequest:request];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (theConnection)
    {
        
        receivedData = [NSMutableData data];
    }
    else
    {
#pragma mark connection failed
        UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"NSURLConnection " message:@"Failed in viewDidLoad"  delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [connectFailMessage show];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    // need to do this every time this view appears so that the "home" link keeps working
    [self.webView loadRequest:request];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
