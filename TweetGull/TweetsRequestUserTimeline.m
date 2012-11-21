//
//  TweetsRequestUserTimeline.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TweetsRequestUserTimeline.h"

@implementation TweetsRequestUserTimeline
-(NSString *)title
{
    return [NSString stringWithFormat:@"@%@",self.user.screen_name];
}
-(NSString *)timeline_url
{
    return [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=%@&count=200&include_entities=1", self.user.screen_name];
}
@end

