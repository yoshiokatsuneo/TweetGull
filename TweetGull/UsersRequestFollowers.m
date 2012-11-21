//
//  UsersRequestFollowers.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 9/26/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "UsersRequestFollowers.h"

@implementation UsersRequestFollowers
-(NSString*)users_url
{
    return [NSString stringWithFormat:@"https://api.twitter.com/1.1/followers/ids.json?cursor=-1&screen_name=%@", self.screen_name];
}
@end
