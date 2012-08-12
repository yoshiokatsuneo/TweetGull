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

@interface TwitterAPI : NSObject
+(TwitterAPI*)defaultTwitterAPI;
- (void)signIn:(UIViewController*)viewController callback:(void (^)(void))callback;
-(void)composeTweet:(UIViewController*)viewController text:(NSString*)text;
-(void)fetchTweets:(UIViewController*)viewController user_screen_name:(NSString*)user_screen_name search_query:(NSString*)search_query callback:(void (^)(Tweets *tweets))callback;


-(Tweet *)favorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet *)unfavorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet *)retweet:(UIViewController*)viewController tweet_id_str:(NSString *)tweet_id_str;
-(void)unretweet:(UIViewController*)viewController tweet_id_str:(NSString *)tweet_id_str;
-(Tweet*)destroyTweet:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet*)getTweet:(NSString*)tweet_id_str;
-(void)signOut;
@end
