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

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize profileImage = _profileImage;
@synthesize nameLabel = _nameLabel;
@synthesize tweetLabel = _tweetLabel;
@synthesize webViewSuperView = _webViewSuperView;
@synthesize retweetUserNameLabel = _retweetUserNameLabel;
@synthesize created_atLabel = _created_atLabel;
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

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        Tweet *tweet = self.detailItem;
        self.nameLabel.text = tweet.user_name;
        self.tweetLabel.text = tweet.display_text;
        self.tweetLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.tweetLabel.numberOfLines = 0;
        self.retweetUserNameLabel.text = tweet.retweet_user_name;
        self.created_atLabel.text = tweet.created_at_str;

        if(tweet.mediaURLString){
            NSString *url = tweet.mediaURLString;
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.mediaImageView = imageView;
            MediaImageCache *mediaImageCache = [MediaImageCache defaultMediaImageCache];
            [mediaImageCache loadToImageView:imageView fromURLString:url];
        
        }else if(tweet.linkURLString){
            NSString *url = tweet.linkURLString;
        
            MyWebView *aWebView = [[WebViewCache defaultWebViewCache] getWebView:url];
            self.webView = aWebView;
        }
        
        ProfileImageCache *profileImageCache = [ProfileImageCache defaultProfileImageCache];
        self.profileImage.image = [profileImageCache getImage:tweet.user_screen_name];
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
        Tweet *tweet = self.detailItem;
        NSString *text = [NSString stringWithFormat:@"@%@ ",tweet.user_screen_name];
        [[TwitterAPI defaultTwitterAPI] composeTweet:self text:text];
    }
}
- (void)startActionSheet:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:nil];
    [sheet addButtonWithTitle:@"Reply"];
    [sheet addButtonWithTitle:@"Retweet"];
    [sheet addButtonWithTitle:@"Favorite"];
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
    [self setTweetLabel:nil];
    [self setWebViewSuperView:nil];
    [self setRetweetUserNameLabel:nil];
    [self setCreated_atLabel:nil];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTweets"]){
        Tweet *tweet = self.detailItem;
        MasterViewController *masterViewController = [segue destinationViewController];
        masterViewController.user_screen_name = tweet.user_screen_name;
    }
}
@end
