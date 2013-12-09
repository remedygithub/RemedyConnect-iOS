//
//  JJGWebView.h
//
//  Created by Jeff Geerling on 2/11/11.
//  Copyright 2011 Midwestern Mac, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJGWebView : UIViewController <UITextFieldDelegate, UIWebViewDelegate> {

	IBOutlet UIToolbar *webViewToolbar;
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIBarButtonItem *refreshButton;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *forwardButton;

	NSURL *webViewURL;

}

@property (nonatomic,strong) UIToolbar *webViewToolbar;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) NSURL *webViewURL;
@property (nonatomic,strong) UIBarButtonItem *refreshButton;
@property (nonatomic,strong) UIBarButtonItem *backButton;
@property (nonatomic,strong) UIBarButtonItem *forwardButton;

@end
