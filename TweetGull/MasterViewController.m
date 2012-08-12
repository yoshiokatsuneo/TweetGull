//
//  MasterViewController.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "WebViewCache.h"
#import "TweetEditViewController.h"
#import "TweetTableViewCellViewController.h"
#import "TweetTableViewCell.h"
#import "Tweets.h"
#import "Tweet.h"
#import "NSString+Parse.h"
#import "ProfileImageCache.h"
#import "MediaImageCache.h"

#import "UIAlertView+alert.h"
#import "TwitterAPI.h"
// #import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit.h>

// #import <BlocksKit/UIActionSheet+BlocksKit.h>

@interface MasterViewController () {
    Tweets *tweets;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(!self){return nil;}
    
    TweetTableViewCellViewController *cellViewController = [[TweetTableViewCellViewController alloc] init];
    [cellViewController loadView];
    TweetTableViewCell *cell = cellViewController.tableViewCell;
    cellHeight = cell.frame.size.height;
    
    return self;
}
- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)leftButtonActionSheet:(id)sender
{
    UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:@"Search"];

    [sheet addButtonWithTitle:@"Logout" handler:^{
        [[TwitterAPI defaultTwitterAPI] signOut];
    }];
    
    [sheet addButtonWithTitle:@"Search" handler:^{
        UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"Search" message:@"Search Message"];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView addButtonWithTitle:@"Search" handler:^{
            self.user_screen_name = nil;
            self.search_query = [alertView textFieldAtIndex:0].text;
            [self performSegueWithIdentifier:@"showTweets" sender:self];
        }];
        [alertView show];
    }];
    [sheet addButtonWithTitle:@"Cancel" handler:^{
        ;
    }];

    [sheet showInView:self.view];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [WebViewCache defaultWebViewCache].delegate = self;
    if(!tweets){
        [[TwitterAPI defaultTwitterAPI] signIn:self callback:^{
            [self fetchTweets];
        }];
    }
    
	// Do any additional setup after loading the view, typically from a nib.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    if(self.user_screen_name == nil){
#if 0
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc ] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
        self.navigationItem.leftItemsSupplementBackButton = YES;
        self.navigationItem.leftBarButtonItems  = [NSArray arrayWithObject:logoutButton];
#endif
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(leftButtonActionSheet:)];
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    if(self.user_screen_name){
        self.title = [NSString stringWithFormat:@"@%@", self.user_screen_name];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#if 0
-(void)tweetEditViewControllerSend:(TweetEditViewController *)tweetEditViewController text:(NSString *)text
{
    NSLog(@"%s: text=%@", __func__, text);
    [tweetEditViewController dismissViewControllerAnimated:YES completion:nil];
    [self postTweet:text];
}
-(void)tweetEditViewControllerCancel:(TweetEditViewController *)tweetEditViewController
{
    NSLog(@"%s", __func__);
    [tweetEditViewController dismissViewControllerAnimated:YES completion:nil];
}
#endif

- (void)insertNewObject:(id)sender
{
    [[TwitterAPI defaultTwitterAPI] composeTweet:self text:@""];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tweets.count;
}
- (void)setTweetLinkInfo:(Tweet*)tweet cellViewController:(TweetTableViewCellViewController*)cellViewController
{
    NSString *url = tweet.linkURLString;
    
    WebViewCache *webViewCache = [WebViewCache defaultWebViewCache];
    if(! [webViewCache isLoaded:url]){
        return;
    }
    MyWebView *myWebView = [webViewCache getWebView:url];
    if(myWebView.startLoadCount > 0){
        cellViewController.progressView.hidden = NO;
        cellViewController.progressView.progress = 1.0*myWebView.startLoadCount / (1.0*myWebView.finishLoadCount);
        // cellViewController.tableViewCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
}

-(void)updateVisibleCellsLink
{
    for(UITableViewCell *tableViewCell in self.tableView.visibleCells){
        int index = tableViewCell.tag;
        Tweet *tweet = [tweets objectAtIndex:index];
        if(tweet.mediaURLString){
            ;
        }else if(tweet.linkURLString){
            NSString *url = tweet.linkURLString;
            if(url){
                WebViewCache *webViewCache = [WebViewCache defaultWebViewCache];
                [webViewCache addURL:url];
            }
        }
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    TweetTableViewCellViewController *cellViewController;
    
    if(cell == nil){
        cellViewController = [[TweetTableViewCellViewController alloc] init];
        [cellViewController loadView];
        cell = cellViewController.tableViewCell;
        cell.viewController = cellViewController;
        // cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TweetCell"];
    }
    cellViewController = cell.viewController;
    int index = indexPath.row;
    Tweet *tweet = [tweets objectAtIndex:index];

    [cellViewController reset];
    
    cell.tag = index;
    // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // cell.textLabel.text = text;
    // cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", name];
    // cell.imageView.image = nil;
    cellViewController.tweetText.text = tweet.display_text;
    cellViewController.userNameLabel.text = tweet.user_name;
    cellViewController.retweetUserNameLabel.text = tweet.retweet_user_name;
    cellViewController.profileImageView.image = nil;
    cellViewController.progressView.progress = 0.0;
    cellViewController.progressView.hidden = YES;
    cellViewController.created_atLabel.text = tweet.created_at_str;
    cellViewController.tweet = tweet;
    
    [self setTweetLinkInfo:tweet cellViewController:cellViewController];
    // cell.imageView.image = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
    
    ProfileImageCache *profileImageCache = [ProfileImageCache defaultProfileImageCache];
    cellViewController.profileImageView.image= [profileImageCache getImage:tweet.user_screen_name];

    if(cellViewController.profileImageView.image == nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = tweet.user_profile_image_url;
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                [profileImageCache addImage:image screen_name:tweet.user_screen_name];
                if(tweet == cell.viewController.tweet){
                    cellViewController.profileImageView.image = image;
                    // [cell.imageView setNeedsDisplay];
                    // [cell.imageView setNeedsLayout];
                    // [cell setNeedsLayout];
                    // [cell setNeedsDisplay];
                }
            });
            
        });
    }

    
//    [self setTweetLinkProgress:tweet progressView:cellViewController.progressView];
    
    NSLog(@"%s: indexPath.row=%d\n", __func__, indexPath.row);
    
    NSString *linkURL = tweet.linkURLString;
    NSString *mediaURL = tweet.mediaURLString;
    
    if(mediaURL){
        MediaImageCache *mediaImageCache = [MediaImageCache defaultMediaImageCache];
        UIImage *image = [mediaImageCache getImage:mediaURL];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        cellViewController.mediaImageView = imageView;
        [mediaImageCache loadToImageView:imageView fromURLString:mediaURL];
    }else if(linkURL){
        WebViewCache *webViewCache = [WebViewCache defaultWebViewCache];
        [webViewCache addURL:linkURL];
        MyWebView *webView = [webViewCache getWebView:linkURL];
        cellViewController.webView = webView;
    }
    
    [self updateVisibleCellsLink];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tweets removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Tweet *tweet = [tweets objectAtIndex:indexPath.row];
        self.detailViewController.tweet = tweet;
    }else{
        [self performSegueWithIdentifier:@"showTweet" sender:self];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTweet"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Tweet *tweet = [tweets objectAtIndex:indexPath.row];
        DetailViewController * detailViewController = [segue destinationViewController];
        detailViewController.tweet = tweet;
    }
    if ([[segue identifier] isEqualToString:@"showTweets"]){
        MasterViewController *masterViewController = [segue destinationViewController];
        masterViewController.search_query = self.next_view_search_query;
    }
}

-(void)fetchTweets
{
    [[TwitterAPI defaultTwitterAPI] fetchTweets:self user_screen_name:self.user_screen_name search_query:self.search_query callback:^(Tweets * tweets_){
        tweets = tweets_;
        [self.tableView reloadData];
        [self stopLoading];
        
    } ];
}
#if 0
-(void)postTweetFetcher:(GTMHTTPFetcher*)fetcher finishedWithData:(NSData*)data error:(NSError*)error
{
    if(error != nil){
        NSLog(@"Fetch error: %@", error);
        return;
    }
    [self fetchTweets];
}
-(void)postTweet:(NSString*)text
{
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *encodedText = [GTMOAuthAuthentication encodedOAuthParameterForString:text];
    NSString *body = [NSString stringWithFormat:@"status=%@", encodedText];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [self signIn:^{
        [auth authorizeRequest:request];
        
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(postTweetFetcher:finishedWithData:error:)];
    }];
}
#endif
- (IBAction)logout:(id)sender {
    [[TwitterAPI defaultTwitterAPI] signOut];
}
- (void)refresh
{
    [self fetchTweets];
    // [self.tableView reloadData];
}
#if 0
-(int)getTableViewCellIndexFromURL:(NSString*)url
{
    int index = -1;
    for(int i=0;i<tweets.count;i++){
        Tweet *tweet = [tweets objectAtIndex:i];
        NSString *url_  = tweet.urlString;
        if([url isEqual:url_]){
            index = i;
        }
    }
    return index;
}
#endif
#if 0
-(void)setTweetStatus:(NSString*)url accessoryType:(UITableViewCellAccessoryType)accessoryType
{
    for(UITableViewCell *tableViewCell in self.tableView.visibleCells){
        int index = tableViewCell.tag;
        Tweet *tweet = [tweets objectAtIndex:index];
        NSString *url_ = tweet.urlString;
        if([url isEqual:url_]){
            UITableViewCell *tableViewCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            tableViewCell.accessoryType = accessoryType; 
        }
        
    }
    
}
#endif
-(void)updateProgress:(NSString*)url progress:(double)progress
{
    for(UITableViewCell *tableViewCell in self.tableView.visibleCells){
        int index = tableViewCell.tag;
        Tweet *tweet = [tweets objectAtIndex:index];
        NSString *url_ = tweet.linkURLString;
        if([url isEqual:url_]){
            TweetTableViewCell *tableViewCell = (TweetTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            TweetTableViewCellViewController *cellViewController =  tableViewCell.viewController;
            cellViewController.progressView.hidden = NO;
            cellViewController.progressView.progress = progress;
        }
        
    }
    
}

-(void)webViewCacheUpdateCounter:(NSString *)url start_counter:(int)start_counter finish_counter:(int)finish_counter
{
    [self updateProgress:url progress:(1.0*finish_counter)/(1.0*start_counter)];
}
-(void)webViewCacheDidFinishLoad:(NSString *)url
{
    ;
    // [self setTweetStatus:url accessoryType:UITableViewCellAccessoryDetailDisclosureButton];
}
-(void)webViewLost:(NSString *)url
{
    ;
    // [self setTweetStatus:url accessoryType:UITableViewCellAccessoryDisclosureIndicator];
}
@end

