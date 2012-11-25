//
//  TweetsRequestMentions.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TweetsRequestMentions.h"

@implementation TweetsRequestMentions
-(NSString *)title
{
    return @"Mentions";
}
-(NSString *)timeline_url
{
    return @"https://api.twitter.com/1.1/statuses/mentions_timeline.json?count=200&include_entities=1";
}
@end
