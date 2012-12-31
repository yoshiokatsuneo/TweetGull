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
#import "TweetsRequestUserTimeline.h"
#import "TweetsRequestRelated.h"
#import "NSJSONSerialization+string.h"
#import "UIAlertView+alert.h"
#import "BlocksKit.h"

@interface DetailViewController ()
{
    id observerWebViewDidFinishLoad;
    id observerWebViewDidStartLoad;
    BOOL isFirstDidAppear;
    __weak UIActionSheet *sheet;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView:(BOOL)bFast;
@end

@implementation DetailViewController
@synthesize relatedTweetsButton = _relatedTweetsButton;

@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize profileImage = _profileImage;
@synthesize nameLabel = _nameLabel;
@synthesize tweetSuperView = _tweetSuperView;
@synthesize tweetWebView = _tweetWebView;
@synthesize webViewSuperView = _webViewSuperView;
@synthesize retweetUserNameLabel = _retweetUserNameLabel;
@synthesize retweetUserNameButton = _retweetUserNameButton;
@synthesize created_atLabel = _created_atLabel;
@synthesize retweetedLabel = _retweetedLabel;
@synthesize favoritedLabel = _favoritedLabel;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        isFirstDidAppear = YES;
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
    }
    mediaWebView_ = mediaWebView;
    if(mediaWebView){
        CGRect frame = CGRectMake(0, 0, self.webViewSuperView.bounds.size.width, self.webViewSuperView.bounds.size.height);
        mediaWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [mediaWebView setFrame:frame];
        [self.webViewSuperView insertSubview:mediaWebView atIndex:0];

    }
}
-(void)setWebView:(MyWebView *)webView
{
    webView.userInteractionEnabled = YES;
    webView.scrollView.scrollsToTop = YES;
    
    webView.thumbnailMode = NO;

    NSString *script = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = 'none';";
    [webView stringByEvaluatingJavaScriptFromString:script];
    
    [self setMediaWebView:webView];
}
-(void)setMediaImageView:(UIImageView *)imageView
{
    [self setMediaWebView:imageView];
}
-(void)setMediaScrollImageView:(UIScrollView *)scrollView
{
    [self setMediaWebView:scrollView];
    scrollView.contentSize = scrollView.bounds.size;
}
-(void)setMediaScrollImageViewFromURL:(NSString*)url
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    [scrollView addSubview:imageView];
    scrollView.contentSize = imageView.frame.size;
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 5.0;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if(scrollView.zoomScale != 1.0){
            [scrollView setZoomScale:1.0 animated:YES];
        }else{
            [scrollView setZoomScale:2.0 animated:YES];
        }
    }];
    [doubleTap setNumberOfTapsRequired:2];
    [scrollView addGestureRecognizer:doubleTap];
    
    
    // self.mediaImageView = imageView;
    self.mediaScrollImageView = scrollView;
    
    MediaImageCache *mediaImageCache = [MediaImageCache defaultMediaImageCache];
    [mediaImageCache loadToImageView:imageView fromURLString:url];
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
    UIScrollView *scrollView = self.mediaScrollImageView;
    if(scrollView){
        UIView *aSubView = scrollView.subviews[0];
        if([aSubView isKindOfClass:[UIImageView class]]){
            return (UIImageView*)aSubView;
        }
    }
    
    if([mediaWebView_ isKindOfClass:[UIImageView class]]){
        return (UIImageView*)mediaWebView_;
    }else{
        return nil;
    }    
}
-(UIScrollView *)mediaScrollImageView
{
    if([mediaWebView_ isKindOfClass:[UIScrollView class]]){
        return (UIScrollView*)mediaWebView_;
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

- (void)configureTitle
{
    NSMutableArray *barButtons = [[NSMutableArray alloc] init];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(startActionSheet:)];
    [barButtons addObject:addButton];
    self.navigationItem.rightBarButtonItem = addButton;
    self.goBackButton.hidden = !(self.webView && self.webView.canGoBack);
    self.goForwardButton.hidden = !(self.webView && self.webView.canGoForward);
    
    self.navigationItem.rightBarButtonItems = barButtons;
}
- (void)configureView:(BOOL)bFast
{
    // Update the user interface for the detail item.

    if (self.tweet) {
        self.nameLabel.text = self.tweet.orig_user.name;
        self.tweetWebView.delegate = self;
        [self.tweetWebView setFrame:self.tweetSuperView.bounds];
        self.tweetWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tweetWebView.scrollView.scrollsToTop = NO;
        [self.tweetSuperView addSubview:self.tweetWebView];
        self.retweetUserNameLabel.text = self.tweet.retweet_user.name;
        self.retweetUserNameButton.enabled = (self.tweet.retweet_user.name != nil);
        self.created_atLabel.text = self.tweet.created_at_str;
        self.retweetedLabel.hidden = (self.tweet.retweeted == NO);
        self.favoritedLabel.hidden = (self.tweet.favorited == NO);
#if 0
        NSArray *user_mentions = [[self.tweet objectForKey:@"entities"] objectForKey:@"user_mentions"];
        id in_reply_to_status_id = [self.tweet objectForKey:@"in_reply_to_status_id"];
        self.relatedTweetsButton.hidden = !((in_reply_to_status_id && in_reply_to_status_id != [NSNull null]) || (user_mentions && user_mentions.count>0));
#endif
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
        if(self.tweet.mediaURLString){
            NSString *url = self.tweet.mediaURLString;
            [self setMediaScrollImageViewFromURL:url];
        }else if(self.tweet.linkURLString){
            {
                NSString *url = self.tweet.linkURLString;
            
                MyWebView *aWebView = [[WebViewCache defaultWebViewCache] getWebView:url];
                
                if(bFast){
                    self.mediaImageView = [[UIImageView alloc] initWithImage:aWebView.thumbnailImage];
                }else{
                    self.webView = aWebView;
                    
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    observerWebViewDidFinishLoad =[center addObserverForName:@"observerWebViewDidFinishLoad" object:aWebView queue:nil usingBlock:^(NSNotification *notification){
                        [self configureTitle];
                    }];
                    observerWebViewDidStartLoad = [center addObserverForName:@"observerWebViewDidStartLoad" object:aWebView queue:nil usingBlock:^(NSNotification *notification){
                        [self configureTitle];
                    }];
                }
            }

        }
        
        ProfileImageCache *profileImageCache = [ProfileImageCache defaultProfileImageCache];
        self.profileImage.image = [profileImageCache getImage:self.tweet.orig_user.screen_name];
#if 0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImage.image = [UIImage imageWithData:data];
            });
                            
        });
#endif
        [self configureTitle];
    }
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mediaImageView;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }
    if(buttonIndex == 1 /*Reply*/){
        NSString *text = [NSString stringWithFormat:@"@%@ ",self.tweet.orig_user.screen_name];
        [[TwitterAPI defaultTwitterAPI] composeTweet:self text:text in_reply_to_status_id_str:self.tweet.id_str callback:nil];
    }else if(buttonIndex == 2 /* Retweet */){
        if(self.tweet.retweeted){
            [[TwitterAPI defaultTwitterAPI] unretweet:self tweet_id_str:self.tweet.id_str ];
            self.tweet.retweeted = NO;
            [self configureView:NO];
        }else{
            [[TwitterAPI defaultTwitterAPI] retweet:self tweet_id_str:self.tweet.id_str];
            self.tweet.retweeted = YES;
            [self configureView:NO];
        }
    }else if(buttonIndex == 3){
        if(self.tweet.favorited){
            [[TwitterAPI defaultTwitterAPI] unfavorite:self tweet_id_str:self.tweet.id_str ];
            self.tweet.favorited = NO;
            [self configureView:NO];
        }else{
            [[TwitterAPI defaultTwitterAPI] favorite:self tweet_id_str:self.tweet.id_str];
            self.tweet.favorited = YES;
            [self configureView:NO];
        }
    }else if (buttonIndex == 4){
        NSString *urlstr = [NSString stringWithFormat:@"https://mobile.twitter.com/%@/status/%@", self.tweet.orig_user.screen_name, self.tweet.id_str];
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
    if(sheet){
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }
    UIActionSheet *sheet_ = [UIActionSheet actionSheetWithTitle:nil];
    sheet = sheet_;
    
    __weak typeof(self) weakself = self;
    // UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:nil];
    [sheet addButtonWithTitle:@"Reply" handler:^{
        NSString *text = [NSString stringWithFormat:@"@%@ ",self.tweet.orig_user.screen_name];
        [[TwitterAPI defaultTwitterAPI] composeTweet:weakself text:text in_reply_to_status_id_str:self.tweet.id_str callback:nil];
    }];
    // [sheet addButtonWithTitle:@"Reply"];
    if(self.tweet.retweeted){
        [sheet addButtonWithTitle:@"Unretweet" handler:^{
            [[TwitterAPI defaultTwitterAPI] unretweet:weakself tweet_id_str:self.tweet.id_str ];
            self.tweet.retweeted = NO;
            [weakself configureView:NO];
        }];
        // [sheet addButtonWithTitle:@"Unretweet"];
    }else{
        [sheet addButtonWithTitle:@"Retweet" handler:^{
            [[TwitterAPI defaultTwitterAPI] retweet:weakself tweet_id_str:self.tweet.id_str];
            self.tweet.retweeted = YES;
            [weakself configureView:NO];
        }];
        // [sheet addButtonWithTitle:@"Retweet"];
    }
    if(self.tweet.favorited){
        [sheet addButtonWithTitle:@"Unfavorite" handler:^{
            [[TwitterAPI defaultTwitterAPI] unfavorite:weakself tweet_id_str:self.tweet.id_str ];
            self.tweet.favorited = NO;
            [weakself configureView:NO];
        }];
        
        // [sheet addButtonWithTitle:@"Unfavorite"];
    }else{
        [sheet addButtonWithTitle:@"Favorite" handler:^{
            [[TwitterAPI defaultTwitterAPI] favorite:weakself tweet_id_str:self.tweet.id_str];
            self.tweet.favorited = YES;
            [weakself configureView:NO];
        }];
        // [sheet addButtonWithTitle:@"Favorite"];
    }
    [sheet addButtonWithTitle:@"Open Tweet in Safari" handler:^{
        NSString *urlstr = [NSString stringWithFormat:@"https://mobile.twitter.com/%@/status/%@", self.tweet.orig_user.screen_name, self.tweet.id_str];
        NSURL *url = [NSURL URLWithString:urlstr];
        [[UIApplication sharedApplication] openURL:url];

    }];
    // [sheet addButtonWithTitle:@"Open Tweet in Safari"];
    
    
    [sheet addButtonWithTitle:@"Open Link in Safari" handler:^{
        NSString *urlstr = self.tweet.urlString;
        NSURL *url = [NSURL URLWithString:urlstr];
        [[UIApplication sharedApplication] openURL:url];
    }];
    // [sheet addButtonWithTitle:@"Open Link in Safari"];
    
    // [sheet showInView:self.view];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // [self configureView];
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
    [self setTweetSuperView:nil];
    [self setRetweetUserNameButton:nil];
    [self setRelatedTweetsButton:nil];
    [self setGoForwardButton:nil];
    [self setGoBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    sleep(0);
    [self configureView:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if(observerWebViewDidFinishLoad){
        [center removeObserver:observerWebViewDidFinishLoad];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    sleep(0);
    [self configureView:NO];

    if(isFirstDidAppear){
        if(self.webView){
            if(self.webView.pendingRequest){
                [self.webView loadRequest:self.webView.pendingRequest];
            }
        }
        isFirstDidAppear = NO;
    }

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



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlstr = request.URL.description;
    NSLog(@"url=%@", urlstr);
    if([urlstr isEqual:@"http://dummy.example.com/"]){
        return YES;
    }
    if([urlstr hasPrefix:@"http://tweet_user/"]){
        NSString *tweet_user_str_percent = [urlstr substringFromIndex:18];
        NSString *tweet_user_str = [tweet_user_str_percent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *tweet_user_dic = [NSJSONSerialization JSONObjectWithString:tweet_user_str options:0 error:&error];
        if(error){
            [UIAlertView alertError:error];
            return NO;
        }
        User *user = [[User alloc] initWithDictionary:tweet_user_dic];
        [self performSegueWithIdentifier:@"showTweets" sender:user];
    }else if([urlstr hasPrefix:@"http://media_url/"]){
        NSString *media_url_str_percent = [urlstr substringFromIndex:17];
        NSString *media_url_str = [media_url_str_percent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self setMediaScrollImageViewFromURL:media_url_str];
    }else if([urlstr hasPrefix:@"http://url/"]){
        NSString *url_str_percent = [urlstr substringFromIndex:11];
        NSString *url_str = [url_str_percent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        MyWebView *aWebView = [[WebViewCache defaultWebViewCache] getWebView:url_str];
        self.webView = aWebView;
    }
        
    sleep(0);
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTweets"]){
        MasterViewController *masterViewController = [segue destinationViewController];
        TweetsRequestUserTimeline * tweetsRequestUserTimeline = [[TweetsRequestUserTimeline alloc] init];
        if([sender isKindOfClass:[User class]]){
            tweetsRequestUserTimeline.user = sender;
            // tweetsRequestUserTimeline.id_str = sender.id_str;
        }else{
            tweetsRequestUserTimeline.user = self.tweet.orig_user;
        }
        masterViewController.tweetsRequest = tweetsRequestUserTimeline;
    }
    if ([[segue identifier] isEqualToString:@"showRetweetTweets"]){
        MasterViewController *masterViewController = [segue destinationViewController];
        TweetsRequestUserTimeline * tweetsRequestUserTimeline = [[TweetsRequestUserTimeline alloc] init];
        tweetsRequestUserTimeline.user = self.tweet.retweet_user;
        masterViewController.tweetsRequest =tweetsRequestUserTimeline;
    }
    if ([segue.identifier isEqualToString:@"showRelatedTweets"]){
        MasterViewController *masterViewController = segue.destinationViewController;
        TweetsRequestRelated * tweetsRequestRelated = [[TweetsRequestRelated alloc] init];
        tweetsRequestRelated.tweet = self.tweet;
        masterViewController.tweetsRequest = tweetsRequestRelated;
    }
}
- (IBAction)goForward:(id)sender {
    // [self.webView stringByEvaluatingJavaScriptFromString:@"history.forward()"];
    [self.webView goForward];
}

- (IBAction)goBack:(id)sender {
    // [self.webView stringByEvaluatingJavaScriptFromString:@"history.back()"];
    [self.webView goBack];
}
@end
