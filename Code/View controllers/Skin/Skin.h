//
//  Skin.h
//  Your Practice
//
//  Created by Adamek Zoltán on 2013.11.20..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Skin : NSObject

+(void)applySplashOnImageView:(UIImageView *)imageView;
+(void)applyMainMenuBGOnImageView:(UIImageView *)imageView;
+(void)applyMainLogoOnImageView:(UIImageView *)imageView;
+(void)applySubLogoOnImageView:(UIImageView *)imageView;
+(void)applyBackgroundOnButton:(UIButton *)button;
+(void)applySubMenuBGOnView:(UITableView *)view;
+(void)reorientBGFrameInViewController:(UIViewController *)viewController;
+(NSString *)logoContentsForWebView;
+(void)applyPageBGOnWebView:(UIWebView *)webView inViewController:(UIViewController *)viewController;
+(NSString *)wrapHTMLBodyWithStyle:(NSString *)bodyText;

@end
