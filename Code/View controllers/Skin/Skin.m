//
//  Skin.m
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.20..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "Skin.h"
#import "FileHandling.h"

@implementation Skin

+(void)applyFile:(NSString *)fileName onImageView:(UIImageView *)imageView {
    NSString *splashPath = [FileHandling getSkinFilePathWithComponent:fileName];
    if (nil != splashPath) {
        UIImage *image = [UIImage imageWithContentsOfFile:splashPath];
        [imageView setImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

+(void)applySplashOnImageView:(UIImageView *)imageView {
    [self applyFile:@"splashscreen.png" onImageView:imageView];
}

+(void)applyMainMenuBGOnImageView:(UIImageView *)imageView {
    [self applyFile:@"background.png" onImageView:imageView];
}

+(void)applyMainLogoOnImageView:(UIImageView *)imageView {
    [self applyFile:@"menulogo.png" onImageView:imageView];
}

+(void)applySubLogoOnImageView:(UIImageView *)imageView {
    [self applyFile:@"logo.png" onImageView:imageView];
}

+(void)applyBackgroundOnButton:(UIButton *)button {
    //NSString *buttonPath = [FileHandling getSkinFilePathWithComponent:@"button.9.png"];
    NSString *buttonPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"testbutton.png"];
    if (nil != buttonPath) {
        UIImage *image = [[UIImage imageWithContentsOfFile:buttonPath] resizableImageWithCapInsets:UIEdgeInsetsMake(16,16,16,16) resizingMode:UIImageResizingModeStretch];
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
}

+(void)applySubMenuBGOnView:(UITableView *)view {
    NSString *bgPath = [FileHandling getSkinFilePathWithComponent:@"background_main.png"];
    if (nil != bgPath) {
        UIImage *image = [UIImage imageWithContentsOfFile:bgPath];
        UIImageView *bg = [[UIImageView alloc] initWithImage:image];
        bg.contentMode = UIViewContentModeScaleAspectFill;
        [view setBackgroundView:bg];
    }
}

+(NSString *)logoContentsForWebView {
    NSString *logoPath = [FileHandling getSkinFilePathWithComponent:@"logo.png"];
    return [NSString stringWithFormat:@"<img src='file://%@' class='headerlogo' />", logoPath];
}

+(void)applyPageBGOnWebView:(UIWebView *)webView inViewController:(UIViewController *)viewController {
    NSString *bgPath = [FileHandling getSkinFilePathWithComponent:@"background_main.png"];
    if (nil != bgPath) {
        UIImage *image = [UIImage imageWithContentsOfFile:bgPath];
        UIImageView *bg = [[UIImageView alloc] initWithImage:image];
        [viewController.view insertSubview:bg belowSubview:webView];
        bg.contentMode = UIViewContentModeScaleAspectFill;
        bg.frame = viewController.view.bounds;
        [webView setBackgroundColor:[UIColor clearColor]];
        [webView setOpaque:NO];
    }
}

+(void)reorientBGFrameInViewController:(UIViewController *)viewController {
    for (UIView *subview in [viewController.view subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *bg = (UIImageView*)subview;
            bg.contentMode = UIViewContentModeScaleAspectFill;
            bg.frame = viewController.view.bounds;
        }
    }
}

+(NSString *)wrapHTMLBodyWithStyle:(NSString *)bodyText {
    NSURL *bundleURL = [[NSBundle mainBundle] resourceURL];
    NSString *cssLink = @"<link rel='stylesheet' href='style.css' type='text/css'/>";
    NSString *format = @"<html><head><base href='%@'/>%@</head><body>%@</body>";
    NSString *result = [[NSString alloc] initWithFormat: format, bundleURL, cssLink, bodyText];
    return result;
}

@end
