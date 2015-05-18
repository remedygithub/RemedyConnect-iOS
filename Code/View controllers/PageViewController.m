//
//  PageViewController.m
//  MyPractice
//
//  Created by Adamek Zoltán on 2013.10.17..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "PageViewController.h"
#import "Logic.h"
#import "Skin.h"
//#import "TestFlight.h"

@interface PageViewController ()

@end

@implementation PageViewController

Logic *logic;

- (void)awakeFromNib {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.navigationController.delegate = self;
    [self performSelector:@selector(reOrient) withObject:nil afterDelay: 0];
}

// Method to handle orientation changes.
- (void)orientationChanged:(NSNotification *)notification
{
    [self performSelector:@selector(reOrient) withObject:nil afterDelay: 0];
}

// Called when a new view is shown.
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    // May be coming back from another controller to find we're
    // showing the wrong controller for the orientation.
    [self performSelector:@selector(reOrient) withObject:nil afterDelay: 0];
}

- (void)reOrient {
    [Skin reorientBGFrameInViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
     NSString *path = [paths objectAtIndex:0];
     NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
     NSString *imageFilePath = [unzipPath stringByAppendingPathComponent:@"background_main.png"];
     NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
     UIImage *img = [UIImage imageWithData:imageData];
    
     NSString *imageFileLogoPath = [unzipPath stringByAppendingPathComponent:@"logo.png"];
    
    
     UIImageView *yourImageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
     [yourImageView setImage:img];
     [yourImageView setContentMode:UIViewContentModeCenter];
     [self.view addSubview:yourImageView];
    
     [_pageWebView setDelegate:self];
     [_pageWebView setOpaque:NO];
     [self.view bringSubviewToFront:_pageWebView];
     [Skin applyPageBGOnWebView:_pageWebView inViewController:self];
    
     logic = [Logic sharedLogic];
    
     NSDictionary *page = [logic getDataToDisplayForPage];
     NSString *title = [page objectForKey:@"title"];
    
    //NSString *text = [NSString stringWithFormat:@"%@ %@",
                     // [Skin logoContentsForWebView],
                      //[page objectForKey:@"text"]];
    NSString *text = [NSString stringWithFormat:@"%@ %@",
                      [Skin logoContentsHeaderForWebView:imageFileLogoPath],
                      [page objectForKey:@"text"]];
    [self setTitle:title];
    
    if (nil != text)
    {
        NSURL *baseURL = [NSURL URLWithString:@""];
        text = [Skin wrapHTMLBodyWithStyle:text];
        NSLog(@"%@",text);
        [_pageWebView loadHTMLString:text baseURL:baseURL];
    }
    ;
}

-(void)viewWillAppear:(BOOL)animated
{
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (nil == parent) {
        [logic unwindBackStack];
    }
}

@end
