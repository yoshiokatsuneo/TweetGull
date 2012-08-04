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
- (id)initWithJSONString:(NSString*)json_str
{
    self = [super init];
    if(!self){return nil;}
    array = [[NSMutableArray alloc] init];
    NSError *error;
    NSData *json_data = [json_str dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *json_array = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingMutableContainers error:&error];
    for (NSDictionary *item in json_array) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:item];
        [array addObject:tweet];
    }    
    return self;
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
