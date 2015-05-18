//
//  MessageDetailsViewController.m
//  RemedyConnect
//
//  Created by Ravindra Kishan on 23/04/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "MessageDetailsViewController.h"
@interface MessageDetailsViewController ()

@end

@implementation MessageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString * pratice = [[NSUserDefaults standardUserDefaults] objectForKey:@"messageLabel"];
    self.practiceNameLabel.text = pratice;
    NSLog(@"%@",self.str1);
    self.label1.text = self.str1;
    self.label2.text = self.str2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuBtnTapped:(id)sender
{
    [self showGrid];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self showGridWithHeaderFromPoint:[longPress locationInView:self.view]];
    }
}

#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
{
    NSLog(@"Dismissed with item %ld: %@", (long)itemIndex, item.title);
    
    switch (itemIndex)
    {
        case 0:
            [self mycareBtn];
            break;
            
        case 1:
            [self myAppointmentsBtn];
            break;
            
        case 2:
            [self myMessagesBtn];
            break;
            
        case 3:
            [self AreYouSickBtn];
            break;
            
        case 4:
            [self OurOfficeBtn];
            break;
            
        case 5:
            [self MarketPlaceBtn];
            break;
            
        default:
            break;
    }
}


#pragma mark - MenuBtn Action
//Care
-(void)mycareBtn
{
    NSLog(@"Care");
}

//Appointments
-(void)myAppointmentsBtn
{
    NSLog(@"myAppointments");
}

//Message
-(void)myMessagesBtn
{
    NSLog(@"myMessages");
}

//Sick
-(void)AreYouSickBtn
{
    NSLog(@"AreYouSick");
}


-(void)OurOfficeBtn
{
    NSLog(@"OurOfficeBtn");
}

//Market
-(void)MarketPlaceBtn
{
    NSLog(@"MarketPlaceBtn");
}

#pragma mark - Private
- (void)showImagesOnly {
    NSInteger numberOfOptions = 5;
    NSArray *images = @[
                        [UIImage imageNamed:@"Circle"],
                        [UIImage imageNamed:@"attachment"],
                        [UIImage imageNamed:@"block"],
                        [UIImage imageNamed:@"bluetooth"],
                        [UIImage imageNamed:@"cube"],
                        [UIImage imageNamed:@"download"],
                        [UIImage imageNamed:@"enter"],
                        [UIImage imageNamed:@"file"],
                        [UIImage imageNamed:@"github"]
                        ];
    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:[images subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    if (IS_IPHONE_6)
    {
         [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/0.7, self.view.bounds.size.height/2.9)];
    }
    else if (IS_IPHONE_5)
    {
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/0.7, self.view.bounds.size.height/2.5)];
    }
   
}

- (void)showList {
    NSInteger numberOfOptions = 5;
    NSArray *options = @[
                         @"My Care",
                         @"Appointments",
                         @"Cancel",
                         @"Messages",
                         @"Are You Sick?",
                         @"Download",
                         @"Our Office",
                         @"Market Place",
                         @"Github"
                         ];
    RNGridMenu *av = [[RNGridMenu alloc] initWithTitles:[options subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    av.itemFont = [UIFont boldSystemFontOfSize:18];
    av.itemSize = CGSizeMake(150, 55);
    if (IS_IPHONE_6)
    {
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/0.7, self.view.bounds.size.height/2.9)];
    }
    else if (IS_IPHONE_5)
    {
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/0.7, self.view.bounds.size.height/2.5)];
    }
}

- (void)showGrid {
    NSInteger numberOfOptions = 6;
    
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"Circle"] title:@"My Care"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"] title:@"Appointments"],
                      [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"Messages"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"Are You Sick?"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"enter"] title:@"Our Office"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Market Place"],
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    if (IS_IPHONE_6)
    {
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/0.7, self.view.bounds.size.height/2.9)];
    }
    else if (IS_IPHONE_5)
    {
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/0.7, self.view.bounds.size.height/2.5)];
    }
}

- (void)showGridWithHeaderFromPoint:(CGPoint)point
{
    NSInteger numberOfOptions = 6;
    NSArray *items = @[
                       [RNGridMenuItem emptyItem],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"] title:@"Appointments"],
                       [RNGridMenuItem emptyItem],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"Messages"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"Are You Sick?"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"Download"],
                       [RNGridMenuItem emptyItem],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Market Place"],
                       [RNGridMenuItem emptyItem]
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    av.bounces = NO;
    av.animationDuration = 0.2;
 
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    header.text = @"Example Header";
    header.font = [UIFont boldSystemFontOfSize:18];
    header.backgroundColor = [UIColor clearColor];
    header.textColor = [UIColor whiteColor];
    header.textAlignment = NSTextAlignmentCenter;
    [av showInViewController:self center:point];
}

- (void)showGridWithPath {
    NSInteger numberOfOptions = 6;
    
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"Circle"] title:@"My Care"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"] title:@"Appointments"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"Messages"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"Are You Sick?"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"enter"] title:@"Our Office"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Market Place"],
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    if (IS_IPHONE_6)
    {
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/0.7, self.view.bounds.size.height/2.9)];
    }
    else if (IS_IPHONE_5)
    {
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/0.7, self.view.bounds.size.height/2.5)];
    }
}

#pragma mark Orientation handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}


@end
