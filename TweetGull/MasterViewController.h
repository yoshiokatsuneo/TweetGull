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

@class DetailViewController;

// @interface MasterViewController : UITableViewController

@interface MasterViewController : PullRefreshTableViewController<WebViewCacheDelegate /*, TweetEditViewControllerDelegate */>
{
    int cellHeight;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *user_screen_name;
-(void)fetchTweets;
- (IBAction)logout:(id)sender;

@end
