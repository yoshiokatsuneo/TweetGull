//
//  MediaImageCache.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaImageCache.h"

static MediaImageCache *m_mediaImageCache = nil;
@implementation MediaImageCache
+(MediaImageCache*) defaultMediaImageCache
{
    if(!m_mediaImageCache){
        m_mediaImageCache = [[MediaImageCache alloc] init];
    }
    return m_mediaImageCache;
}
- (id)init
{
    self = [super init];
    if(!self){return nil;}
    cache = [[LRUCache alloc] init:10];
    return self;
}
- (UIImage*)getImage:(NSString*)url
{
    return [cache objectForKey:url];
}
- (void)addImage:(UIImage*)image forURLString:(NSString*)urlString
{
    if(image == nil){return;}
    [cache setObject:image forKey:urlString];
}
- (void)loadToImageView:(UIImageView*)imageView fromURLString:(NSString*)url
{
    imageView.image = [self getImage:url];
    if(imageView.image == nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (imageView.superview == nil){
                return;
            }
            NSRange range = [url rangeOfString:@"instagram://media?id="];
            NSString *imageurl = url;
            if(range.location == 0){
                NSString *idstr = [url substringFromIndex:range.length];
                NSString *url2 = [NSString stringWithFormat:@"http://instagram.com/api/v1/oembed/?url=http://instagr.am/p/%@/&maxwidth=480", idstr];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url2]];
                NSError *error;
                NSHTTPURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                NSLog(@"Error: %@\n", error);
                NSLog(@"statusCode: %d\n", response.statusCode);
                if(error || response.statusCode != 200){
                    return;
                }
                NSString *json_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                // NSString *json_str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url2] encoding:NSUTF8StringEncoding error:&error];
                
                NSData *json_data = [json_str dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingMutableContainers error:&error];
                imageurl = [dic objectForKey:@"url"];
                
            }
            NSError *error;
            NSHTTPURLResponse *response = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageurl]];
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSLog(@"Error: %@\n", error);
            NSLog(@"statusCode: %d\n", response.statusCode);
            if(error || response.statusCode != 200){
                return;
            }
            // NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                [self addImage:image forURLString:url];
                if(imageView.superview){
                    imageView.image = image;
                }
            });
        });
    }
}
@end
