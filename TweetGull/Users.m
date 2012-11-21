//
//  Users.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 9/26/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "Users.h"

@implementation Users
-(NSUInteger)count
{
    return [array count];
}
-(id)objectAtIndex:(NSUInteger)index
{
    return [array objectAtIndex:index];
}
-(id)initWithJSONArray:(NSArray *)json_array
{
    self = [super init];
    array = json_array;
    return self;
}
@end
