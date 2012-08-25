//
//  TwitterAPI.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/7/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweets.h"
#import "Tweet.h"
#import "TweetsRequest.h"

enum {TWEETS_KIND_MENSIONS = 1, TWEETS_KIND_FAVORITES, TWEETS_KIND_SEARCH};

@interface TwitterAPI : NSObject
+(TwitterAPI*)defaultTwitterAPI;
- (void)signIn:(UIViewController*)viewController callback:(void (^)(void))callback;
- (void)signInReal:(UIViewController*)viewController callback:(void (^)(void))callback;
-(void)composeTweet:(UIViewController*)viewController text:(NSString*)text in_reply_to_status_id_str:(NSString*)in_reply_to_status_id_str;
-(void)fetchTweets:(UIViewController*)viewController tweetsRequest:(TweetsRequest*)tweetsRequest callback:(void (^)(Tweets *tweets))callback;

-(Tweet *)favorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet *)unfavorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet *)retweet:(UIViewController*)viewController tweet_id_str:(NSString *)tweet_id_str;
-(void)unretweet:(UIViewController*)viewController tweet_id_str:(NSString *)tweet_id_str;
-(Tweet*)destroyTweet:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet*)getTweet:(NSString*)tweet_id_str;
-(void)signOut;

@property(readonly) NSString *screen_name;
@property(readwrite) NSString *authPersistenceResponseString;
@end
