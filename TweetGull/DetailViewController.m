//
//  DetailViewController.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewCache.h"
#import "Tweet.h"
#import "ProfileImageCache.h"
#import "MediaImageCache.h"
#import "MasterViewController.h"
#import "TwitterAPI.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize profileImage = _profileImage;
@synthesize nameLabel = _nameLabel;
// @synthesize tweetTextView = _tweetTextView;
@synthesize tweetWebView = _tweetWebView;
@synthesize webViewSuperView = _webViewSuperView;
@synthesize retweetUserNameLabel = _retweetUserNameLabel;
@synthesize created_atLabel = _created_atLabel;
@synthesize retweetedLabel = _retweetedLabel;
@synthesize favoritedLabel = _favoritedLabel;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        ;
    }
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    sleep(0);
}
-(void)setMediaWebView:(UIView *)mediaWebView
{
    if(mediaWebView_){
        [mediaWebView_ removeFromSuperview];
        if([mediaWebView_ isKindOfClass:[MyWebView class]]){
            MyWebView *webView = (MyWebView*)mediaWebView_;
            webView.userInteractionEnabled = NO;
        }
        [mediaWebView_ setFrame:orig_webViewFrame];
        [orig_superView addSubview:mediaWebView_];
    }
    mediaWebView_ = mediaWebView;
    if(mediaWebView){
        orig_webViewFrame = mediaWebView.frame;
        orig_superView =  mediaWebView.superview;
        CGRect frame = CGRectMake(0, 0, self.webViewSuperView.bounds.size.width, self.webViewSuperView.bounds.size.height);
        mediaWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [mediaWebView setFrame:frame];
        [self.webViewSuperView addSubview:mediaWebView];

    }
}
-(void)setWebView:(MyWebView *)webView
{
    webView.userInteractionEnabled = YES;
    [self setMediaWebView:webView];
}
-(void)setMediaImageView:(UIImageView *)imageView
{
    [self setMediaWebView:imageView];
}
-(MyWebView *)webView
{
    if([mediaWebView_ isKindOfClass:[MyWebView class]]){
        return (MyWebView*)mediaWebView_;
    }else{
        return nil;
    }
}
-(UIImageView *)mediaImageView
{
    if([mediaWebView_ isKindOfClass:[UIImageView class]]){
        return (UIImageView*)mediaWebView_;
    }else{
        return nil;
    }    
}
#if 0
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        // [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
        
    }        
}
#endif
- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.tweet) {
        self.nameLabel.text = self.tweet.user_name;
        // self.tweetTextView.text = self.tweet.display_text;
        NSString *html = [NSString stringWithFormat:@"<BODY style=\"font-size:small; font-familly:System; padding:0px; margin:0px; vertical-align:middle; height:100%%;\"><div style=\"vertical-align:middle;\">%@</div></BODY>", self.tweet.display_html];
        [self.tweetWebView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://dummy.example.com/"]];
        // [self.tweetTextView setValue:self.tweet.htmlText forKey:@"contentToHTMLString"];
        self.retweetUserNameLabel.text = self.tweet.retweet_user_name;
        self.created_atLabel.text = self.tweet.created_at_str;
        self.retweetedLabel.hidden = (self.tweet.retweeted == NO);
        self.favoritedLabel.hidden = (self.tweet.favorited == NO);
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
        if(self.tweet.mediaURLString){
            NSString *url = self.tweet.mediaURLString;
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.mediaImageView = imageView;
            MediaImageCache *mediaImageCache = [MediaImageCache defaultMediaImageCache];
            [mediaImageCache loadToImageView:imageView fromURLString:url];
        
        }else if(self.tweet.linkURLString){
            NSString *url = self.tweet.linkURLString;
        
            MyWebView *aWebView = [[WebViewCache defaultWebViewCache] getWebView:url];
            self.webView = aWebView;
        }
        
        ProfileImageCache *profileImageCache = [ProfileImageCache defaultProfileImageCache];
        self.profileImage.image = [profileImageCache getImage:self.tweet.user_screen_name];
#if 0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImage.image = [UIImage imageWithData:data];
            });
                            
        });
#endif
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }
    if(buttonIndex == 1 /*Reply*/){
        NSString *text = [NSString stringWithFormat:@"@%@ ",self.tweet.user_screen_name];
        [[TwitterAPI defaultTwitterAPI] composeTweet:self text:text in_reply_to_status_id_str:self.tweet.id_str];
    }else if(buttonIndex == 2 /* Retweet */){
        if(self.tweet.retweeted){
            [[TwitterAPI defaultTwitterAPI] unretweet:self tweet_id_str:self.tweet.id_str ];
            self.tweet.retweeted = NO;
            [self configureView];
        }else{
            [[TwitterAPI defaultTwitterAPI] retweet:self tweet_id_str:self.tweet.id_str];
            self.tweet.retweeted = YES;
            [self configureView];
        }
    }else if(buttonIndex == 3){
        if(self.tweet.favorited){
            [[TwitterAPI defaultTwitterAPI] unfavorite:self tweet_id_str:self.tweet.id_str ];
            self.tweet.favorited = NO;
            [self configureView];
        }else{
            [[TwitterAPI defaultTwitterAPI] favorite:self tweet_id_str:self.tweet.id_str];
            self.tweet.favorited = YES;
            [self configureView];
        }
    }else if (buttonIndex == 4){
        NSString *urlstr = [NSString stringWithFormat:@"https://mobile.twitter.com/%@/status/%@", self.tweet.user_screen_name, self.tweet.id_str];
        NSURL *url = [NSURL URLWithString:urlstr];
        [[UIApplication sharedApplication] openURL:url];
    }else if (buttonIndex == 5){
        NSString *urlstr = self.tweet.urlString;
        NSURL *url = [NSURL URLWithString:urlstr];
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (void)startActionSheet:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:nil];
    [sheet addButtonWithTitle:@"Reply"];
    if(self.tweet.retweeted){
        [sheet addButtonWithTitle:@"Unretweet"];
    }else{
        [sheet addButtonWithTitle:@"Retweet"];
    }
    if(self.tweet.favorited){
        [sheet addButtonWithTitle:@"Unfavorite"];
    }else{
        [sheet addButtonWithTitle:@"Favorite"];
    }
    [sheet addButtonWithTitle:@"Open Tweet in Safari"];
    [sheet addButtonWithTitle:@"Open Link in Safari"];
    [sheet showInView:self.view];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // [self configureView];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(startActionSheet:)];
    self.navigationItem.rightBarButtonItem = addButton;

}

- (void)viewDidUnload
{
    [self setProfileImage:nil];
    [self setNameLabel:nil];
    [self setWebViewSuperView:nil];
    [self setRetweetUserNameLabel:nil];
    [self setCreated_atLabel:nil];
    [self setRetweetedLabel:nil];
    [self setFavoritedLabel:nil];
    // [self setTweetTextView:nil];
    [self setTweetWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    sleep(0);
    [self configureView];
}
-(void)viewDidAppear:(BOOL)animated
{
    sleep(0);
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (IBAction)gotoUser:(id)sender {
    // Tweet *tweet = self.detailItem;
    sleep(0);
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlstr = request.URL.description;
    NSLog(@"url=%@", urlstr);
    if([urlstr isEqual:@"http://dummy.example.com/"]){
        return YES;
    }
    if([[urlstr substringToIndex:19] isEqual:@"http://screen_name:"]){
        NSString *screen_name2 = [urlstr substringFromIndex:19];
        [self performSegueWithIdentifier:@"showTweets" sender:screen_name2];
    }
    sleep(0);
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTweets"]){
        MasterViewController *masterViewController = [segue destinationViewController];
        if([sender isKindOfClass:[NSString class]]){
            masterViewController.user_screen_name = sender;
        }else{
            masterViewController.user_screen_name = self.tweet.user_screen_name;
        }
    }
}
@end
