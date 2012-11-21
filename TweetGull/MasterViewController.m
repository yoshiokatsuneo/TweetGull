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
#import "Accounts.h"

#import "UIAlertView+alert.h"
#import "TwitterAPI.h"
// #import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit.h>
#import "TweetsRequestSearch.h"
#import "TweetsRequestFavorites.h"
#import "TweetsRequestHomeTimeline.h"
#import "TweetsRequestMentions.h"
#import "TweetsRequestUserTimeline.h"
#import "TweetsRequestDirectMessages.h"
#import "UsersTableViewController.h"
#import "UsersRequestFriends.h"
#import "UsersRequestFollowers.h"


// #import <BlocksKit/UIActionSheet+BlocksKit.h>

@interface MasterViewController () {
    Tweets *tweets;
    NSMutableDictionary *tweetWebViewDic;
    User *user_;
    NSArray *connections;
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
    tweetWebViewDic = [[NSMutableDictionary alloc] init];
    
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
-(User*)summary_user
{
    User *user = nil;
    if([self.tweetsRequest isKindOfClass:[TweetsRequestUserTimeline class]]){
        TweetsRequestUserTimeline *tweetsRequestUserTimeline = (TweetsRequestUserTimeline*)self.tweetsRequest;
        user = tweetsRequestUserTimeline.user;
    }else{
        user = [TwitterAPI defaultTwitterAPI].user;
    }
    return user;
}
-(User*)user
{
    if(user_){
        return user_;
    }
    return [self summary_user];
}
-(void)setUser:(User *)user
{
    user_ = user;
}
#if 0
-(NSString *)screen_name
{
    NSString *name = nil;
    if([self.tweetsRequest isKindOfClass:[TweetsRequestUserTimeline class]]){
        TweetsRequestUserTimeline *tweetsRequestUserTimeline = (TweetsRequestUserTimeline*)self.tweetsRequest;
        name = tweetsRequestUserTimeline.user_screen_name;
    }else{
        name = [TwitterAPI defaultTwitterAPI].screen_name;
    }
    return name;
}
-(NSString *)id_str
{
    NSString *name = nil;
    if([self.tweetsRequest isKindOfClass:[TweetsRequestUserTimeline class]]){
        TweetsRequestUserTimeline *tweetsRequestUserTimeline = (TweetsRequestUserTimeline*)self.tweetsRequest;
        ; //name = tweetsRequestUserTimeline.id_str;
    }else{
        name = [TwitterAPI defaultTwitterAPI].user_id;
    }
    return name;
}
#endif

- (void)loadTitle
{
    self.title = self.tweetsRequest.title;
#if 0
    if(self.user_screen_name){
        self.title = [NSString stringWithFormat:@"@%@", self.user_screen_name];
    }else if(self.search_query){
        self.title = [NSString stringWithFormat:@"%@", self.search_query];
    }else if(self.tweet_for_related){
        self.title = self.tweet_for_related.display_text;
    }else{
        self.title = [NSString stringWithFormat:@"Home(@%@)", [TwitterAPI defaultTwitterAPI].screen_name ];
    }
#endif
}
- (void)accountTableViewControllerDidFinish:(AccountTableViewController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
    tweets = nil;
    [self loadCurrentAccount];
    [self.tableView reloadData];

    self.tweetsRequest = nil;
    [self fetchTweets];
}
- (void)rightButtonActionSheet:(id)sender
{
    UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:@"Search"];


    [sheet addButtonWithTitle:@"Tweet" handler:^{
        [self insertNewObject:self];
    }];
    
    [sheet addButtonWithTitle:@"Logout" handler:^{
        [[TwitterAPI defaultTwitterAPI] signOut];
    }];
    
    if([self.tweetsRequest isKindOfClass:[TweetsRequestUserTimeline class]]){
        if([connections containsObject:@"following"]){
            [sheet addButtonWithTitle:[NSString stringWithFormat:@"Unfollow @%@", self.user.screen_name] handler:^{
                [[TwitterAPI defaultTwitterAPI] unfollow:self user_id_str:self.user.id_str];
            }];
        }else{
            [sheet addButtonWithTitle:[NSString stringWithFormat:@"Follow @%@", self.user.screen_name] handler:^{
                [[TwitterAPI defaultTwitterAPI] follow:self user_id_str:self.user.id_str];
            }];
        }
    }
    
    [sheet addButtonWithTitle:@"\U0001F50D Search" handler:^{
        UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"Search" message:@"Search Message"];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView addButtonWithTitle:@"Search" handler:^{
            TweetsRequestSearch *tweetsRequestSearch = [[TweetsRequestSearch alloc] init];
            tweetsRequestSearch.query = [alertView textFieldAtIndex:0].text;
            self.nextTweetsRequest = tweetsRequestSearch;
            [self performSegueWithIdentifier:@"showTweets" sender:self];
        }];
        [alertView setCancelButtonWithTitle:nil handler:nil];
        [alertView show];
    }];

    [sheet addButtonWithTitle:@"Mensions" handler:^{
        self.nextTweetsRequest = [[TweetsRequestMentions alloc] init];
        [self performSegueWithIdentifier:@"showTweets" sender:self];
    }];
    [sheet addButtonWithTitle:@"Direct Messages" handler:^{
        self.nextTweetsRequest = [[TweetsRequestDirectMessages alloc] init];
        [self performSegueWithIdentifier:@"showTweets" sender:self];
    }];
    [sheet addButtonWithTitle:@"\U00002B50 Favorites" handler:^{
        TweetsRequestFavorites *tweetsRequestFavorites = [[TweetsRequestFavorites alloc] init];
        tweetsRequestFavorites.user_screen_name = self.user.screen_name;
        self.nextTweetsRequest = tweetsRequestFavorites;
        [self performSegueWithIdentifier:@"showTweets" sender:self];
    }];

    [sheet addButtonWithTitle:@"Switch User" handler:^{
        AccountTableViewController *controller = [[AccountTableViewController alloc] init];
        controller.delegate = self;
        [self presentModalViewController:controller animated:YES];
    }];

    [sheet addButtonWithTitle:@"Friends" handler:^{
        UsersRequestFriends *usersRequest = [[UsersRequestFriends alloc] init];
        usersRequest.screen_name = self.user.screen_name;
        [self performSegueWithIdentifier:@"showUsers" sender:usersRequest];
    }];
    [sheet addButtonWithTitle:@"Followers" handler:^{
        UsersRequestFollowers *usersRequest = [[UsersRequestFollowers alloc] init];
        usersRequest.screen_name = self.user.screen_name;
        [self performSegueWithIdentifier:@"showUsers" sender:usersRequest];
        
    }];
    
    
    [sheet setCancelButtonWithTitle:nil handler:nil];

    [sheet showInView:self.view];
}
- (void)loadCurrentAccount
{
    TwitterAPI *twitterAPI = [TwitterAPI defaultTwitterAPI];
    NSString *name = [Accounts currentAccount];
    if(name){
        NSString *password = [[Accounts defaultAccounts] passwordForAccount:name];
        if(password && password.length > 0){
            [twitterAPI setAuthPersistenceResponseString:password];
        }
    }
}
- (void)initialSignIn:(void (^)(void))callback
{
    TwitterAPI *tmpTwitterAPI = [[TwitterAPI alloc] init ];
    [tmpTwitterAPI signInReal:self callback:^{
        if(tmpTwitterAPI.user.screen_name){
            NSString *password = tmpTwitterAPI.authPersistenceResponseString;
            Accounts *accounts = [Accounts defaultAccounts];
            [accounts setPassword:password forAccount:tmpTwitterAPI.user.screen_name];
            [Accounts setCurrentAccount:tmpTwitterAPI.user.screen_name];
            callback();
        }else{
            [self initialSignIn:callback];
        }
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [WebViewCache defaultWebViewCache].delegate = self;
    
    
    TwitterAPI *twitterAPI = [TwitterAPI defaultTwitterAPI];
    if(twitterAPI.user.screen_name == nil){
        [self loadCurrentAccount];
    }
    if(twitterAPI.user.screen_name == nil){
        [self initialSignIn:^{
            [self loadCurrentAccount];
            [self fetchTweets];
        }];
    }else{
        [self fetchTweets];
    }

#if 0
    if(!tweets){
        [[TwitterAPI defaultTwitterAPI] signIn:self callback:^{
            [self fetchTweets];
        }];
    }
#endif
	// Do any additional setup after loading the view, typically from a nib.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;

#if 0
    if(self.user_screen_name == nil && self.search_query == nil && self.tweet_for_related == nil){
#if 0
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc ] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
        self.navigationItem.leftItemsSupplementBackButton = YES;
        self.navigationItem.leftBarButtonItems  = [NSArray arrayWithObject:logoutButton];
#endif
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(leftButtonActionSheet:)];
        self.navigationItem.leftBarButtonItem = leftButton;
        
    }
#endif
    
    //if(self.tweetsRequest == nil || [self.tweetsRequest isKindOfClass:[TweetsRequestHomeTimeline class]]){
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(rightButtonActionSheet:)];
        self.navigationItem.rightBarButtonItem = rightButton;
    //}
    
    // UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(insertNewObject:)];
    // self.navigationItem.rightBarButtonItem = addButton;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateVisibleCellsLink:nil];
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
    [[TwitterAPI defaultTwitterAPI] composeTweet:self text:@"" in_reply_to_status_id_str:nil callback:^(bool result){
        if(result){
            [self performSelector:@selector(fetchTweets) withObject:nil afterDelay:0.5];
            // [self fetchTweets];
        }
    }];
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

-(void)updateVisibleCellsLinkItr:(TweetTableViewCell *)current_cell create:(BOOL)fCreate
{
    NSMutableDictionary *new_dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *visibleCells = [NSMutableArray arrayWithArray:self.tableView.visibleCells];
    if(current_cell){
        [visibleCells addObject:current_cell];
    }
    
    for(TweetTableViewCell *cell in visibleCells){
        int index = cell.tag;
        TweetTableViewCellViewController *cellViewController = cell.viewController;
        Tweet *tweet = [tweets objectAtIndex:index];
        if(tweet.mediaURLString){
            ;
        }else if(tweet.linkURLString){
            NSString *url = tweet.linkURLString;
            if(url){
                if(cellViewController.webView == nil){
                    WebViewCache *webViewCache = [WebViewCache defaultWebViewCache];
                    if(fCreate || [webViewCache isCached:url]){
                        [webViewCache addURL:url];
                        MyWebView *webView = [webViewCache getWebView:url];
                        cellViewController.webView = webView;
                    }
                }
            }
        }
        UIWebView *webView = [tweetWebViewDic objectForKey:tweet.id_str];
        if(webView == nil){
            webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,274,77)];
            /* Ref: Vertically and horizontally center HTML in UIWebView ( http://stackoverflow.com/questions/10882180/vertically-and-horizontally-center-html-in-uiwebview ) */
            webView.scalesPageToFit = YES;
            NSString *html = [NSString stringWithFormat:@"<html><head><meta name='viewport' content='initial-scale=1.0'/><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%%;height: 100%%;font-size:small; font-familly:System;}html {display: table;}body {display: table-cell;vertical-align: middle;padding: 0;text-align: left;-webkit-text-size-adjust: none;}</style></head><body>%@</body></html>​", tweet.display_html]; /* line-height:1.5; (only for Japanese ??) */
            [webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://dummy.example.com/"]];
        }
        [new_dic setObject:webView forKey:tweet.id_str];
    }
    
    tweetWebViewDic = new_dic;

    // Stop scrolling
    // [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
}

-(void)updateVisibleCellsLink:(TweetTableViewCell *)current_cell
{
    [self updateVisibleCellsLinkItr:current_cell create:YES];
}
-(void)updateVisibleCellsLinkIfCached:(TweetTableViewCell *)current_cell
{
    [self updateVisibleCellsLinkItr:current_cell create:NO];
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
    cellViewController.userNameLabel.text = tweet.orig_user.name;
    cellViewController.retweetUserNameLabel.text = tweet.retweet_user.name;
    cellViewController.profileImageView.image = nil;
    cellViewController.progressView.progress = 0.0;
    cellViewController.progressView.hidden = YES;
    cellViewController.created_atLabel.text = tweet.created_at_str;
    cellViewController.tweet = tweet;
    
    [self setTweetLinkInfo:tweet cellViewController:cellViewController];
    // cell.imageView.image = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
    
    ProfileImageCache *profileImageCache = [ProfileImageCache defaultProfileImageCache];
    cellViewController.profileImageView.image= [profileImageCache getImage:tweet.orig_user.screen_name];

    if(cellViewController.profileImageView.image == nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = tweet.orig_user.profile_image_url;
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                [profileImageCache addImage:image screen_name:tweet.orig_user.screen_name];
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
        ;
        // WebViewCache *webViewCache = [WebViewCache defaultWebViewCache];
        // [webViewCache addURL:linkURL];
        // MyWebView *webView = [webViewCache getWebView:linkURL];
        // cellViewController.webView = webView;
        WebViewCache *webViewCache = [WebViewCache defaultWebViewCache];
        if([webViewCache isCached:linkURL]){
            MyWebView *webView = [webViewCache getWebView:linkURL];
            UIImage *image = webView.thumbnailImageView;
            if(image){
                cellViewController.mediaWebView = [[UIImageView alloc] initWithImage:image];
            }
        }
        // cellViewController.mediaWebView = [[UIView alloc] init]; /* dummy view */
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVisibleCellsLink:) object:nil];
    [self performSelector:@selector(updateVisibleCellsLink:) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode /* , NSRunLoopCommonModes */]];
    // [self performSelector:@selector(updateVisibleCellsLink:) withObject:nil afterDelay:0.0];
    //[self updateVisibleCellsLinkIfCached:cell];
    // [self updateVisibleCellsLink:cell];
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
#if 0
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Tweet *tweet = [tweets objectAtIndex:indexPath.row];
        self.detailViewController.tweet = tweet;
    }else{
#endif
        [self performSegueWithIdentifier:@"showTweet" sender:self];
#if 0
    }
#endif
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
        UIWebView *tweetWebView = [tweetWebViewDic objectForKey:tweet.id_str];
        DetailViewController * detailViewController = [segue destinationViewController];
        detailViewController.tweet = tweet;
        detailViewController.tweetWebView = tweetWebView;
    }
    if ([[segue identifier] isEqualToString:@"showTweets"]){
        MasterViewController *masterViewController = [segue destinationViewController];
        masterViewController.tweetsRequest = self.nextTweetsRequest;
    }
    if ([[segue identifier] isEqualToString:@"showUsers"]){
        UsersTableViewController *usersTableViewController = [segue destinationViewController];
        usersTableViewController.usersRequest = (UsersRequest*)sender;
    }
}

-(void)fetchTweets
{
    NSLog(@"=======fetchtweet========");
    if(self.tweetsRequest == nil){
        TweetsRequestHomeTimeline *tweetsRequestHomeTimeline = [[TweetsRequestHomeTimeline alloc] init];
        tweetsRequestHomeTimeline.user = [TwitterAPI defaultTwitterAPI].user;
        self.tweetsRequest = tweetsRequestHomeTimeline;
    }
    [self loadTitle];
    [[TwitterAPI defaultTwitterAPI] fetchTweets:self tweetsRequest:self.tweetsRequest callback:^(Tweets * tweets_){
        tweets = tweets_;
        [self.tableView reloadData];
        [self stopLoading];
        if([self.tweetsRequest isKindOfClass:[TweetsRequestUserTimeline class]]){
#if 0
            [[TwitterAPI defaultTwitterAPI] lookupUser:self id_str:self.user.id_str callback:^(User *user2){
                self.user = user2;
            }];
#endif
            [[TwitterAPI defaultTwitterAPI] lookupConnections:self id_str:self.user.id_str callback:^(NSArray* connections_){
                connections = connections_;
            }];
        }
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

#if 0
-(void)webViewCacheUpdateCounter:(NSString *)url start_counter:(int)start_counter finish_counter:(int)finish_counter
{
    [self updateProgress:url progress:(1.0*finish_counter)/(1.0*start_counter)];
}
#endif

-(void)webViewCacheUpdateProgress:(NSString *)url progress:(double)progress
{
    [self updateProgress:url progress:progress];
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

