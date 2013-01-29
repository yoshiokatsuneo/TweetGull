//
//  Misc.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 1/28/13.
//  Copyright (c) 2013 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterAPI.h"

@interface Misc : NSObject
+(void)askToTweetAboutInstallation:(UIViewController*)viewController twitterAPI:(TwitterAPI*)twitterAPI;
+(void)askToFollowTweetGull:(UIViewController*)viewController twitterAPI:(TwitterAPI*)twitterAPI callback:(void (^)(void))callback;
@end
