//
//  GPItemListWithHTMLCell.h
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.12..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPItemListWithHTMLCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@end
