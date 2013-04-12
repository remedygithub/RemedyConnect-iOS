//
//  JJGWebView.m
//
//  Created by Jeff Geerling on 2/11/11.
//  Copyright 2011 Midwestern Mac, LLC. All rights reserved.
//

#import "JJGWebView.h"

@implementation JJGWebView

@synthesize webViewToolbar, webView, webViewURL, refreshButton, backButton, forwardButton;

#pragma mark Regular controller methods

- (void)viewDidLoad {
    [super viewDidLoad];
	[activityIndicator startAnimating];
	if (webViewURL != nil) {
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:webViewURL];
		[webView loadRequest:requestObj];
	} else {
		NSLog(@"What to do? We don't have a URL...");
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	// We allow rotation.
    return YES;
}

#pragma mark Web View methods

- (void)webViewDidStartLoad:(UIWebView *)wv {
	[activityIndicator startAnimating];
	self.refreshButton.enabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	[activityIndicator stopAnimating];
	self.refreshButton.enabled = YES;

	[backButton setEnabled:[webView canGoBack]]; // Enable or disable back
	[forwardButton setEnabled:[webView canGoForward]]; // Enable or disable forward

	// Set the title of the new page.
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
	[activityIndicator stopAnimating];

	// Make sure there's an actual error, and the error is not -999 (JS-induced, or WebKit bug)
    if (error != NULL && ([error code] != NSURLErrorCancelled)) {
		// NSLog(@"Error: %@", error);

		if ([error code] != NSURLErrorCancelled) {
			//show error alert, etc.
		}
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error Loading Page"
                                                             message:[error localizedFailureReason]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:TRUE];
}

@end
