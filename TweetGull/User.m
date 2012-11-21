//
//  User.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 10/10/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "User.h"

@implementation User

#pragma mark - Primitive methods

-(id)initWithDictionary:(NSDictionary *)otherDictionary
{
    self = [super init];
    dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary];
    return self;
}
-(NSUInteger)count
{
    return dic.count;
}
-(id)objectForKey:(id)aKey
{
    return [dic objectForKey:aKey];
}
-(NSEnumerator *)keyEnumerator
{
    return dic.keyEnumerator;
}
-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    [dic setObject:anObject forKey:aKey];
}
-(void)removeObjectForKey:(id)aKey
{
    [dic removeObjectForKey:aKey];
}

#pragma mark - Added methods
-(NSString *)id_str
{
    return dic[@"id_str"];
}
-(NSString *)name
{
    return dic[@"name"];
}
-(NSString *)screen_name
{
    return dic[@"screen_name"];
}
-(NSString *)profile_image_url
{
    return dic[@"profile_image_url"];
}
@end

