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
    [self setMediaWebView:nil];
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

//-(void)delayedSetNeedsLayout:(id)dummy
//{
//    [mediaWebView_ setNeedsLayout];
//}
-(void)setMediaWebView:(UIView *)mediaWebView
{
    [self.mediaWebView removeFromSuperview];
    
    CGRect frame = CGRectMake(0, 0, self.webViewSuperView.bounds.size.width, self.webViewSuperView.bounds.size.height);
    [mediaWebView setFrame:frame];
    
    // [self performSelector:@selector(delayedSetNeedsLayout:) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
    [mediaWebView setNeedsLayout];
    
    mediaWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.webViewSuperView addSubview:mediaWebView];
    mediaWebView_ = mediaWebView;
    if(mediaWebView == nil){
        CGRect tweetTextFrame = CGRectMake(tweetText.frame.origin.x, tweetText.frame.origin.y, tweetText.superview.bounds.size.width - tweetText.frame.origin.x, tweetText.frame.size.height);
        [tweetText setFrame:tweetTextFrame];
    }else{
        CGRect tweetTextFrame = CGRectMake(tweetText.frame.origin.x, tweetText.frame.origin.y, tweetText.superview.bounds.size.width - tweetText.frame.origin.x - self.webViewSuperView.frame.size.width, tweetText.frame.size.height);
        [tweetText setFrame:tweetTextFrame];
    }
}
-(UIView*)mediaWebView
{
    if([self.webViewSuperView.subviews containsObject:mediaWebView_]){
        return mediaWebView_;
    }else{
        return nil;
    }
}

-(void)setWebView:(MyWebView *)webView
{
    [self setMediaWebView:webView];
    webView.scalesPageToFit = YES;
    webView.userInteractionEnabled = NO;
    webView.scrollView.scrollsToTop = NO;
    [webView stringByEvaluatingJavaScriptFromString:@"javascript:if(history.length>1){history.go(-history.length+1)} scroll(0,0)"];
    // [webView.scrollView setContentOffset:CGPointMake(0, 0)];
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
        if([self.webViewSuperView.subviews containsObject:mediaWebView_]){
            return (MyWebView*)mediaWebView_;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}
@end

