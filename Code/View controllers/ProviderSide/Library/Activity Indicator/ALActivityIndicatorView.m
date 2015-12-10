//
//  ALActivityIndicatorView.m
//  iStadium
//
//  Created by Ravindra Kishan on 9/16/13.
//  Copyright (c) 2013 Ravindra Kishan. All rights reserved.
//

#import "ALActivityIndicatorView.h"

@implementation ALActivityIndicatorView

@synthesize m_cActivityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.0];
        
        m_cActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        CGSize screenSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
		m_cActivityIndicator.center = CGPointMake(screenSize.width/2, screenSize.height/2);
		m_cActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
		|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
		[self addSubview:m_cActivityIndicator];
    }
    return self;
}

//starts animation of the activity indicator after adding it to the main view
- (void)startAnimating
{
	[m_cActivityIndicator startAnimating];
	[[self superview] addSubview:self];
}

//stops animation of the activity indicator before removing it from the main view
- (void)stopAnimating
{
	[m_cActivityIndicator stopAnimating];
	[self removeFromSuperview];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
