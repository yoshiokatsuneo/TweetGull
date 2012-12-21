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
#import "Users.h"
#import "UsersRequest.h"
#import "GTMOAuthAuthentication.h"

enum {TWEETS_KIND_MENSIONS = 1, TWEETS_KIND_FAVORITES, TWEETS_KIND_SEARCH};

@interface TwitterAPI : NSObject
+(TwitterAPI*)defaultTwitterAPI;
- (void)signIn:(UIViewController*)viewController callback:(void (^)(void))callback;
- (void)signInReal:(UIViewController*)viewController callback:(void (^)(void))callback;
-(void)composeTweet:(UIViewController*)viewController text:(NSString*)text in_reply_to_status_id_str:(NSString*)in_reply_to_status_id_str callback:(void(^)(bool result))callback;
-(void)lookupUser:(UIViewController*)viewController id_str:(NSString*)id_str callback:(void (^)(User*))callback;
-(void)lookupConnections:(UIViewController*)viewController id_str:(NSString*)id_str callback:(void (^)(NSArray*))callback;
-(void)fetchTweets:(UIViewController*)viewController tweetsRequest:(TweetsRequest*)tweetsRequest callback:(void (^)(Tweets *tweets))callback;
-(void)fetchUsers:(UIViewController*)viewController usersRequest:(UsersRequest*)usersRequest callback:(void (^)(Users*))callback;
-(Tweet *)favorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet *)unfavorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet *)retweet:(UIViewController*)viewController tweet_id_str:(NSString *)tweet_id_str;
-(void)unretweet:(UIViewController*)viewController tweet_id_str:(NSString *)tweet_id_str;
-(User*)follow:(UIViewController*)viewController user_id_str:(NSString*)user_id_str;
-(User*)unfollow:(UIViewController*)viewController user_id_str:(NSString*)user_id_str;
-(User*)userShow:(UIViewController*)viewController user_id_str:(NSString*)user_id_str;

-(Tweet*)destroyTweet:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
-(Tweet*)getTweet:(NSString*)tweet_id_str;
-(void)signOut;

@property(readonly) User *user;
@property(readonly) GTMOAuthAuthentication *auth;
// @property(readonly) NSString *screen_name;
// @property(readonly) NSString *user_id;
@property(readwrite) NSString *authPersistenceResponseString;
@end
