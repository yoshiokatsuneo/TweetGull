//
//  ProfileImageCache.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileImageCache.h"

static ProfileImageCache *m_profileImageCache = nil;
@implementation ProfileImageCache
+(ProfileImageCache *)defaultProfileImageCache
{
    if(m_profileImageCache == nil){
        m_profileImageCache = [[ProfileImageCache alloc] init];
    }
    return m_profileImageCache;
}
- (id)init
{
    self = [super init];
    if(!self){return nil;}
    
    cache = [[LRUCache alloc] init:100];
    
    return self;
}
- (void)addImage:(UIImage*)image screen_name:(NSString*)screen_name
{
    if(image == nil){return;}
    [cache setObject:image forKey:screen_name];
}
- (UIImage*)getImage:(NSString*)screen_name
{
    return [cache objectForKey:screen_name];
}
@end
