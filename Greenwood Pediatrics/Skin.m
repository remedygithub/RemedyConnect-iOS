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
    }
}

+(void)applySplashOnImageView:(UIImageView *)imageView {
    [self applyFile:@"splashscreen.png" onImageView:imageView];
}

+(void)applyMainMenuBGOnImageView:(UIImageView *)imageView {
    [self applyFile:@"background.png" onImageView:imageView];
}

+(void)applyBackgroundOnButton:(UIButton *)button {
    NSString *buttonPath = [FileHandling getSkinFilePathWithComponent:@"button.9.png"];
    if (nil != buttonPath) {
        UIImage *image = [UIImage imageWithContentsOfFile:buttonPath];
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
}

@end
