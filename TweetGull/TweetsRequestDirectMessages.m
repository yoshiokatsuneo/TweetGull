//
//  TweetsRequestDirectMessages.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TweetsRequestDirectMessages.h"

@implementation TweetsRequestDirectMessages
-(NSString *)title
{
    return @"Direct Messages";
}
-(NSString *)timeline_url
{
    return @"https://api.twitter.com/1/direct_messages.json?count=200&include_entities=1";
}
-(NSArray *)tweetArrayFromResponseJSONObj:(id)json_obj
{
    if(! [json_obj isKindOfClass:[NSArray class]]){
        return nil;
    }
    NSArray *json_array = json_obj;
    for (NSMutableDictionary *json_dic in json_array) {
        NSDictionary *sender = [json_dic objectForKey:@"sender"];
        [json_dic setObject:sender forKey:@"user"];
    }
    return json_array;
}
@end
