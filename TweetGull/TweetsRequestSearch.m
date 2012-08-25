//
//  TweetsRequestSearch.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TweetsRequestSearch.h"
#import "NSString+Encoder.h"

@implementation TweetsRequestSearch
-(NSString *)title
{
    return [NSString stringWithFormat:@"\U0001F50D%@", self.query];
}
-(NSString *)timeline_url
{
    return [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@&rpp=100&include_entities=true&result_type=mixed", [self.query percentEncodeString]];
}
-(NSArray *)tweetArrayFromResponseJSONObj:(id)json_obj
{
    if(! [json_obj isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    NSDictionary *json_dic = json_obj;
    NSArray *json_array = [json_dic objectForKey:@"results"];
    return json_array;
}
@end
