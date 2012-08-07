//
//  DetailViewController.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyWebView.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIActionSheetDelegate>
{
    UIView *mediaWebView_;
    CGRect orig_webViewFrame;
    UIView *orig_superView;
}
- (IBAction)gotoUser:(id)sender;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *tweetLabel;
@property (strong, nonatomic) IBOutlet UIView *webViewSuperView;
@property (strong, nonatomic) IBOutlet UILabel *retweetUserNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *created_atLabel;
@property MyWebView *webView;
@property UIImageView *mediaImageView;
@end
