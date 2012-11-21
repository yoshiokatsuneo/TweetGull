//
//  MasterViewController.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "WebViewCache.h"
#import "TweetEditViewController.h"
#import "AccountTableViewController.h"
#import "Tweet.h"
#import "TweetsRequest.h"

@class DetailViewController;

// @interface MasterViewController : UITableViewController

@interface MasterViewController : PullRefreshTableViewController<WebViewCacheDelegate /*, TweetEditViewControllerDelegate */, AccountTableViewControllerDelegate>
{
    int cellHeight;
}
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#if 0
@property (strong, nonatomic) NSString *user_screen_name;
@property (strong, nonatomic) NSString *search_query;
@property (strong, nonatomic) Tweet *tweet_for_related;
@property int tweets_kind;
@property int next_tweets_kind;
@property (strong, nonatomic) NSString *next_search_query;
@property (strong, nonatomic) NSString *next_user_screen_name;
#endif

@property (strong, nonatomic) TweetsRequest *tweetsRequest;
@property (strong, nonatomic) TweetsRequest *nextTweetsRequest;
@property(readonly) NSString *screen_name;


-(void)fetchTweets;
- (IBAction)logout:(id)sender;

@end
