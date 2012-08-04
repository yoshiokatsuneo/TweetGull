//
//  TweetTableViewCellViewController.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TweetTableViewCellViewController.h"
#import "TweetTableViewCell.h"

@interface TweetTableViewCellViewController ()

@end

@implementation TweetTableViewCellViewController
@synthesize profileImageView;
@synthesize userNameLabel;
@synthesize tweetText;
@synthesize tableViewCell;
@synthesize progressView;
@synthesize webViewSuperView;
@synthesize created_atLabel;
@synthesize retweetUserNameLabel;
@synthesize tweet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setProfileImageView:nil];
    [self setUserNameLabel:nil];
    [self setTweetText:nil];
    [self setTableViewCell:nil];
    [self setProgressView:nil];
    [self setWebViewSuperView:nil];
    [self setCreated_atLabel:nil];
    [self setRetweetUserNameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)reset
{
    self.tweetText.text = @"";
    self.userNameLabel.text = @"";
    self.profileImageView.image = nil;
    self.progressView.progress = 0.0;
    self.progressView.hidden = YES;
    self.tweet = nil;
    self.webView = nil;
}

-(void)setMediaWebView:(UIView *)mediaWebView
{
    [mediaWebView_ removeFromSuperview];
    
    CGRect frame = CGRectMake(0, 0, self.webViewSuperView.bounds.size.width, self.webViewSuperView.bounds.size.height);
    [mediaWebView setFrame:frame];
    [mediaWebView setNeedsLayout];
    mediaWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.webViewSuperView addSubview:mediaWebView];
    mediaWebView_ = mediaWebView;
}
-(void)setWebView:(MyWebView *)webView
{
    [self setMediaWebView:webView];
    webView.scalesPageToFit = YES;
    webView.userInteractionEnabled = NO;
}
-(void)setMediaImageView:(UIImageView*)imageView
{
    [self setMediaWebView:imageView];
}
-(UIImageView *)mediaImageView
{
    if([mediaWebView_ isKindOfClass:[UIImageView class]]){
        return (UIImageView*)mediaWebView_;
    }else{
        return nil;
    }
}
-(MyWebView*)webView
{
    if([mediaWebView_ isKindOfClass:[MyWebView class]]){
        return (MyWebView*)mediaWebView_;
    }else{
        return nil;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}
@end

