//
//  ProfileImageCache.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRUCache.h"

@interface ProfileImageCache : NSObject
{
    LRUCache *cache;
}
+(ProfileImageCache*)defaultProfileImageCache;
- (void)addImage:(UIImage*)image screen_name:(NSString*)screen_name;
- (UIImage*)getImage:(NSString*)screen_name;
@end
