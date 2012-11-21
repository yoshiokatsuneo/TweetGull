//
//  UsersRequestFriends.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 9/26/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "UsersRequestFriends.h"

@implementation UsersRequestFriends
-(NSString*)users_url
{
    return [NSString stringWithFormat:@"https://api.twitter.com/1.1/friends/ids.json?cursor=-1&screen_name=%@", self.screen_name];
}
@end
