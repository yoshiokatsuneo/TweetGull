//
//  MediaImageCache.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRUCache.h"
@interface MediaImageCache : NSObject
{
    LRUCache *cache;
}
+(MediaImageCache*) defaultMediaImageCache;
- (UIImage*)getImage:(NSString*)url;
- (void)addImage:(UIImage*)image forURLString:(NSString*)urlString;
- (void)loadToImageView:(UIImageView*)imageView fromURLString:(NSString*)url;
@end
