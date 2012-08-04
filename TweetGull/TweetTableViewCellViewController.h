//
//  TweetTableViewCellViewController.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyWebView.h"
#import "Tweet.h"
@class TweetTableViewCell;

@interface TweetTableViewCellViewController : UIViewController
{
    UIView *mediaWebView_;
}
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (strong, nonatomic) IBOutlet TweetTableViewCell *tableViewCell;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *webViewSuperView;
@property (weak, nonatomic) IBOutlet UILabel *created_atLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetUserNameLabel;
@property Tweet *tweet;
@property MyWebView *webView;
@property UIImageView *mediaImageView;
-(void)reset;
@end
