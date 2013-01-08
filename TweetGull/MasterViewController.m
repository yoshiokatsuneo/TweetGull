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


@interface MasterViewController () {
    Tweets *tweets;
    NSMutableDictionary *tweetWebViewDic;
    User *user_;
    NSArray *connections;
    __weak UIActionSheet *sheet;
    
    NSMutableArray *observerWebViewDidCaptureThumbNails;
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
    
    observerWebViewDidCaptureThumbNails = [[NSMutableArray alloc] init];
    
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

- (void)loadTitle
{
    self.title = self.tweetsRequest.title;
}
- (void)accountTableViewControllerDidFinish:(AccountTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    tweets = nil;
    [self loadCurrentAccount];
    [self.tableView reloadData];

    self.tweetsRequest = nil;
    [self fetchTweets];
}

- (NSString *)appNameAndVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@, Version %@ (%@)",
            appDisplayName, majorVersion, minorVersion];
}

- (void)rightButtonActionSheet:(id)sender
{
    if(sheet){
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }
    UIActionSheet *sheet_ = [UIActionSheet actionSheetWithTitle:nil];
    sheet = sheet_;
    __weak typeof(self) weakself = self;
    [sheet addButtonWithTitle:@"\U0001F4DD Tweet" handler:^{
        [weakself insertNewObject:weakself];
    }];
    
    
    if([self.tweetsRequest isKindOfClass:[TweetsRequestUserTimeline class]]){
        if([connections containsObject:@"following"]){
            [sheet addButtonWithTitle:[NSString stringWithFormat:@"Unfollow @%@", self.user.screen_name] handler:^{
                [[TwitterAPI defaultTwitterAPI] unfollow:weakself user_id_str:self.user.id_str];
            }];
        }else{
            [sheet addButtonWithTitle:[NSString stringWithFormat:@"Follow @%@", self.user.screen_name] handler:^{
                [[TwitterAPI defaultTwitterAPI] follow:weakself user_id_str:self.user.id_str];
            }];
        }
    }
    
    if([self.tweetsRequest isKindOfClass:[TweetsRequestHomeTimeline class]]){
        [sheet addButtonWithTitle:@"\U0001F50D Search" handler:^{
            UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"Search" message:@"Search Message"];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView addButtonWithTitle:@"Search" handler:^{
                TweetsRequestSearch *tweetsRequestSearch = [[TweetsRequestSearch alloc] init];
                tweetsRequestSearch.query = [alertView textFieldAtIndex:0].text;
                self.nextTweetsRequest = tweetsRequestSearch;
                [weakself performSegueWithIdentifier:@"showTweets" sender:weakself];
            }];
            [alertView setCancelButtonWithTitle:nil handler:nil];
            [alertView show];
        }];

        [sheet addButtonWithTitle:@"\U0000FF20 Mensions" handler:^{
            self.nextTweetsRequest = [[TweetsRequestMentions alloc] init];
            [weakself performSegueWithIdentifier:@"showTweets" sender:weakself];
        }];
        [sheet addButtonWithTitle:@"\U0001F4AC Direct Messages" handler:^{
            self.nextTweetsRequest = [[TweetsRequestDirectMessages alloc] init];
            [weakself performSegueWithIdentifier:@"showTweets" sender:weakself];
        }];
    }
    
    [sheet addButtonWithTitle:@"\U00002B50 Favorites" handler:^{
        TweetsRequestFavorites *tweetsRequestFavorites = [[TweetsRequestFavorites alloc] init];
        tweetsRequestFavorites.user_screen_name = self.user.screen_name;
        self.nextTweetsRequest = tweetsRequestFavorites;
        [weakself performSegueWithIdentifier:@"showTweets" sender:weakself];
    }];
    [sheet addButtonWithTitle:@"\U0001F604 Friends" handler:^{
        UsersRequestFriends *usersRequest = [[UsersRequestFriends alloc] init];
        usersRequest.screen_name = self.user.screen_name;
        [weakself performSegueWithIdentifier:@"showUsers" sender:usersRequest];
    }];
    [sheet addButtonWithTitle:@"\U0001F3C3 Followers" handler:^{
        UsersRequestFollowers *usersRequest = [[UsersRequestFollowers alloc] init];
        usersRequest.screen_name = self.user.screen_name;
        [weakself performSegueWithIdentifier:@"showUsers" sender:usersRequest];
        
    }];

    /*
    [sheet addButtonWithTitle:@"Logout" handler:^{
        [[TwitterAPI defaultTwitterAPI] signOut];
    }];
     */

    if([self.tweetsRequest isKindOfClass:[TweetsRequestHomeTimeline class]]){
        [sheet addButtonWithTitle:@"\U00002194 Switch User" handler:^{
            AccountTableViewController *controller = [[AccountTableViewController alloc] init];
            controller.delegate = self;
            [weakself presentViewController:controller animated:YES completion:nil];
        }];

        [sheet addButtonWithTitle:@"\U0001F4AD About" handler:^{
            NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
            NSError *error;
            NSString *about = [NSString stringWithContentsOfFile:[ mainBundlePath stringByAppendingPathComponent:@"about.txt"] encoding:NSUTF8StringEncoding error:&error];

            NSString *verstr = [weakself appNameAndVersionNumberDisplayString];
            NSString *message = [NSString stringWithFormat:@"%@\n%@", verstr, about];
            
                                                                                                                                                                                                  
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"About" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertView show];
        }];
    }
    
    
    [sheet setCancelButtonWithTitle:nil handler:nil];

    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
    // [sheet showInView:self.view];
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
    TwitterAPI *twitterAPI = [[TwitterAPI alloc] init ];
    [twitterAPI signInReal:self callback:^{
        if(twitterAPI.user.screen_name){
            NSString *password = twitterAPI.authPersistenceResponseString;
            Accounts *accounts = [Accounts defaultAccounts];
            [accounts setPassword:password forAccount:twitterAPI.user.screen_name];
            [Accounts setCurrentAccount:twitterAPI.user.screen_name];
            
            User * user = [twitterAPI userShow:self user_id_str:@"760178030" /* "tweetgull" */];
            NSNumber * following_status = user[@"following"];
            BOOL following_status_bool = [following_status isKindOfClass:[NSNumber class]] && following_status.boolValue;
            if(following_status_bool == NO){
                [UIAlertView showAlertViewWithTitle:@"Do you follow @tweetgull ?" message:nil cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:@[NSLocalizedString(@"Yes", nil)] handler:^(UIAlertView *alertView, NSInteger result){
                    if(result == 1){
                        [twitterAPI follow:self user_id_str:@"760178030" /* "tweetgull" */];
                    }
                }];
            }
            
            callback();
        }else{
            [UIAlertView showAlertViewWithTitle:@"Twitter login failed" message:@"Please retry to login Twitter" cancelButtonTitle:@"Login" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger result){
                [self performSelector:@selector(initialSignIn:) withObject:callback afterDelay:0];
            }];
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
        [self performSelector:@selector(initialSignIn:) withObject:^{
            [self loadCurrentAccount];
            [self fetchTweets];
            
        } afterDelay:0];
    }else{
        [self fetchTweets];
    }

	// Do any additional setup after loading the view, typically from a nib.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;

    
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
    [self updateVisibleCellsLink:nil useThumbnail:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    for(id observer in observerWebViewDidCaptureThumbNails){
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [observerWebViewDidCaptureThumbNails removeAllObjects];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateVisibleCellsLink:nil useThumbnail:NO];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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

-(void)updateVisibleCellsLinkItr:(TweetTableViewCell *)current_cell create:(BOOL)fCreate useThumbnail:(BOOL)useThumbnail
{
    
    for(id observer in observerWebViewDidCaptureThumbNails){
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [observerWebViewDidCaptureThumbNails removeAllObjects];

    
    NSMutableDictionary *new_dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *visibleCells = [NSMutableArray arrayWithArray:self.tableView.visibleCells];
    if(current_cell){
        [visibleCells addObject:current_cell];
    }

    for(TweetTableViewCell *cell in visibleCells){
        int index = cell.tag;
        TweetTableViewCellViewController *cellViewController = cell.viewController;
        Tweet *tweet = [tweets objectAtIndex:index];
        if(cellViewController.webView){
            NSString *url = tweet.linkURLString;
            WebViewCache *webViewCache = [WebViewCache defaultWebViewCache];
            [webViewCache addURL:url]; // to mark recently used
        }
    }

    
    
    NSMutableSet *usedURLs = [[NSMutableSet alloc] init];
    for(TweetTableViewCell *cell in visibleCells){
        int index = cell.tag;
        TweetTableViewCellViewController *cellViewController = cell.viewController;
        Tweet *tweet = [tweets objectAtIndex:index];
        if(tweet.mediaURLString){
            ;
        }else if(tweet.linkURLString){
            NSString *url = tweet.linkURLString;
            WebViewCache *webViewCache = [WebViewCache defaultWebViewCache];
            if(cellViewController.webView == nil){
                if(fCreate || [webViewCache isCached:url]){
                    [webViewCache addURL:url];
                    MyWebView *webView = [webViewCache getWebView:url];
                    if(useThumbnail || [usedURLs member:url]){
                        UIImage *image = webView.thumbnailImage;
                        if(image){
                            if(cellViewController.mediaImageView){
                                cellViewController.mediaImageView.image = image;
                            }else{
                                cellViewController.mediaImageView = [[UIImageView alloc] initWithImage:image];
                            }
                        }
                    }else{
                        cellViewController.webView = webView;
                    }
                }
            }
            if(cellViewController.webView){
                cellViewController.progressView.hidden = NO;
                cellViewController.progressView.progress = cellViewController.webView.estimatedProgress;
                
                id observerWebViewDidCaptureThumbNail =[[NSNotificationCenter defaultCenter] addObserverForName:@"observerWebViewDidCaptureThumbNail" object:cellViewController.webView queue:nil usingBlock:^(NSNotification *notification){
                    if(self.isViewLoaded && self.view.window){
                        [self performSelector:@selector(updateVisibleCellsLink:) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
                    }
                }];
                [observerWebViewDidCaptureThumbNails addObject:observerWebViewDidCaptureThumbNail];
            }else{
                cellViewController.progressView.hidden = YES;
            }
            
            if(cellViewController.webView && ![usedURLs member:url]){
                [usedURLs addObject:url];
            }

        }
        UIWebView *webView = [tweetWebViewDic objectForKey:tweet.id_str];
        if(webView == nil){
            webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,274,77)];
            /* Ref: Vertically and horizontally center HTML in UIWebView ( http://stackoverflow.com/questions/10882180/vertically-and-horizontally-center-html-in-uiwebview ) */
            webView.scalesPageToFit = YES;
            NSString *html = [NSString stringWithFormat:@"<html><head><meta name='viewport' content='initial-scale=1.0'/><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%%;height: 100%%;font-size:small; font-familly:System;}html {display: table;}body {display: table-cell;vertical-align: middle;padding: 0;text-align: left;-webkit-text-size-adjust: none; line-height: 1.3em;}</style></head><body>%@</body></html>​", tweet.display_html]; /* line-height:1.5; (only for Japanese ??) */
            [webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://dummy.example.com/"]];
        }
        [new_dic setObject:webView forKey:tweet.id_str];
    }
    
    tweetWebViewDic = new_dic;

    // Stop scrolling
    // [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
}

-(void)updateVisibleCellsLink:(TweetTableViewCell *)current_cell useThumbnail:(BOOL)useThumbnail
{
    // NSLog(@"mode=%@\n",[NSRunLoop currentRunLoop].currentMode);
    UIPanGestureRecognizer *recognizer = self.tableView.panGestureRecognizer;
    CGPoint velocity = [self.tableView.panGestureRecognizer velocityInView:self.tableView];
    // NSLog(@"state=%d, velocity=%lf", recognizer.state, velocity.y);
    if([[NSRunLoop currentRunLoop].currentMode isEqual:UITrackingRunLoopMode /* NSRunLoopCommonModes */]){
        /* if dragging(!=0), and velocity is slow, update */
        if(fabs(velocity.y) >= 50 || !(recognizer.state == UIGestureRecognizerStateChanged || recognizer.state == UIGestureRecognizerStateBegan)){
            [self performSelector:@selector(updateVisibleCellsLink:) withObject:nil afterDelay:0.3 inModes:@[NSRunLoopCommonModes]];
            return;
        }
    }
    [self updateVisibleCellsLinkItr:current_cell create:YES useThumbnail:useThumbnail];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVisibleCellsLink:) object:nil];

}
-(void)updateVisibleCellsLink:(TweetTableViewCell *)current_cell
{
    [self updateVisibleCellsLink:current_cell useThumbnail:NO];
}
-(void)updateVisibleCellsLinkIfCached:(TweetTableViewCell *)current_cell useThumbnail:(BOOL)useThumbnail
{
    [self updateVisibleCellsLinkItr:current_cell create:NO useThumbnail:useThumbnail];
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
    }
    cellViewController = cell.viewController;
    int index = indexPath.row;
    Tweet *tweet = [tweets objectAtIndex:index];

    [cellViewController reset];
    
    cell.tag = index;
    cellViewController.tweetText.text = tweet.display_text;
    cellViewController.userNameLabel.text = tweet.orig_user.name;
    cellViewController.retweetUserNameLabel.text = tweet.retweet_user.name;
    cellViewController.created_atLabel.text = tweet.created_at_str;
    cellViewController.tweet = tweet;
    
    // [self setTweetLinkInfo:tweet cellViewController:cellViewController];
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
        if([webViewCache isCached:linkURL]){
            MyWebView *webView = [webViewCache getWebView:linkURL];
            UIImage *image = webView.thumbnailImage;
            if(image){
                cellViewController.mediaWebView = [[UIImageView alloc] initWithImage:image];
            }
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVisibleCellsLink:) object:nil];
    [self performSelector:@selector(updateVisibleCellsLink:) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode /* , NSRunLoopCommonModes */]];
    [self performSelector:@selector(updateVisibleCellsLink:) withObject:nil afterDelay:0.3 inModes:@[NSRunLoopCommonModes]];
    // [self performSelector:@selector(updateVisibleCellsLink:) withObject:nil afterDelay:0.0];
    //[self updateVisibleCellsLinkIfCached:cell];
    // [self updateVisibleCellsLink:cell];

    // CGPoint velocity = [self.tableView.panGestureRecognizer velocityInView:self.tableView];
    // NSLog(@"###velocity=%lf\n", velocity.y);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
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
- (IBAction)logout:(id)sender {
    [[TwitterAPI defaultTwitterAPI] signOut];
}
- (void)refresh
{
    [self fetchTweets];
    // [self.tableView reloadData];
}
-(void)updateProgress:(NSString*)url progress:(double)progress
{
    if(self.isViewLoaded && self.view.window){
        [self performSelector:@selector(updateVisibleCellsLink:) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
    }

#if 0
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
#endif
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

