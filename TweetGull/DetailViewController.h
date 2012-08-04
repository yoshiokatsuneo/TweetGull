//
//  DetailViewController.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyWebView.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>
{
    UIView *mediaWebView_;
    CGRect orig_webViewFrame;
    UIView *orig_superView;
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIView *webViewSuperView;
@property (weak, nonatomic) IBOutlet UILabel *retweetUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *created_atLabel;
@property MyWebView *webView;
@property UIImageView *mediaImageView;
@end
