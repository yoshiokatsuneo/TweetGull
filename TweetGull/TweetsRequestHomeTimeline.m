//
//  TweetsRequestHomeTimeline.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TweetsRequestHomeTimeline.h"

@implementation TweetsRequestHomeTimeline
-(NSString *)title
{
    // U+1F3E0 = emoji for Home
    // return [NSString stringWithFormat:@"\ue415\n(@%@)", self.screen_name];
    return [NSString stringWithFormat:@"\U0001F3E0@%@", self.user.screen_name];
}
-(NSString *)timeline_url
{
    return @"https://api.twitter.com/1.1/statuses/home_timeline.json?count=200&include_entities=1";
}
@end
