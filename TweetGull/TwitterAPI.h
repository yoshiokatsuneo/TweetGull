//
//  TwitterAPI.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/7/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweets.h"

@interface TwitterAPI : NSObject
+(TwitterAPI*)defaultTwitterAPI;
- (void)signIn:(UIViewController*)viewController callback:(void (^)(void))callback;
-(void)composeTweet:(UIViewController*)viewController text:(NSString*)text;
-(void)fetchTweets:(UIViewController*)viewController user_screen_name:(NSString*)user_screen_name callback:(void (^)(Tweets *tweets))callback;
-(void)signOut;
@end
