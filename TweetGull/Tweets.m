//
//  Tweets.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweets.h"
#import "Tweet.h"
@implementation Tweets
- (id)initWithJSONArray:(NSArray *)json_array
{
    self = [super init];
    array = [[NSMutableArray alloc] init];
    for(NSDictionary *item in json_array){
        Tweet *tweet = [[Tweet alloc] initWithDictionary:item];
        [array addObject:tweet];
    }
    return self;
}
- (id)initWithJSONString:(NSString*)json_str
{
    NSError *error;
    NSData *json_data = [json_str dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *json_array = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingMutableContainers error:&error];
    return [self initWithJSONArray:json_array];
}
-(NSUInteger)count
{
    return array.count;
}
-(id)objectAtIndex:(NSUInteger)index
{
    return [array objectAtIndex:index];
}
@end
