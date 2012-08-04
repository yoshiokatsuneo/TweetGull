//
//  LRUCache.m
//  LRUCache
//
//  Created by Tsuneo Yoshioka on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LRUCache.h"

@implementation LRUCache
@synthesize countLimit;

- (id)init:(int)countLimit_
{
    self = [super init];
    if(!self){return nil;}
    array = [[NSMutableArray alloc] init];
    dic = [[NSMutableDictionary alloc] init];
    countLimit = countLimit_;
    return self;
}
-(void)removeLastObject
{
    id last_key = [array objectAtIndex:(array.count - 1)];
    [dic removeObjectForKey:last_key];
    [array removeObjectAtIndex:(array.count - 1)];
}
-(void)setObject:(id)obj forKey:(id)key
{
    [array removeObject:key];
    if(countLimit && array.count == countLimit){
        [self removeLastObject];
    }
    [array insertObject:key atIndex:0];
    [dic setObject:obj forKey:key];
}
-(id)objectForKey:(id)key
{
    return [dic objectForKey:key];
}
@end
