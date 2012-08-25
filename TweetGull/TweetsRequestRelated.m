//
//  TweetsRequestRelated.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TweetsRequestRelated.h"

@implementation TweetsRequestRelated
-(NSString *)title
{
    return self.tweet.display_text;
}
-(NSString *)timeline_url
{
    return [NSString stringWithFormat:@"http://api.twitter.com/1/related_results/show/%@.json?include_entities=true&count=200", self.tweet.id_str];
}
-(NSArray *)tweetArrayFromResponseJSONObj:(id)json_obj
{
    if(! [json_obj isKindOfClass:[NSArray class]]){
        return nil;
    }
    NSArray *json_array = json_obj;
    if(json_array.count == 0){
        return nil;
    }
    NSDictionary * json_dic = [json_array objectAtIndex:0];
    if(! [json_dic isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    NSString *resultType = [json_dic objectForKey:@"resultType"];
    if(![resultType isEqualToString:@"Tweet"]){
        return nil;
    }

    json_array = [json_dic objectForKey:@"results"];
    if(! [json_array isKindOfClass:[NSArray class]]){
        return nil;
    }
    
    NSMutableArray *json_array2 = [[NSMutableArray alloc] init];
    for(NSDictionary *json_dic2 in json_array){
        NSDictionary *json_dic3 = [json_dic2 objectForKey:@"value"];
        [json_array2 addObject:json_dic3];
    }
    [json_array2 addObject:self.tweet];
    [json_array2 sortUsingComparator:(NSComparator)^(id obj1, id obj2){
        Tweet *tweet1 = [[Tweet alloc] initWithDictionary:obj1];
        Tweet *tweet2 = [[Tweet alloc] initWithDictionary:obj2];
        NSDate *date1 = tweet1.created_at_date;
        NSDate *date2 = tweet2.created_at_date;
        return [date2 compare:date1];
    }];
    
    return json_array2;
}

@end

