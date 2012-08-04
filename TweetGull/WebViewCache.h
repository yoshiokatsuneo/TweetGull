//
//  WebViewCache.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRUCache.h"
#import "MyWebView.h"

@class WebViewCache;

@protocol WebViewCacheDelegate <NSObject>

-(void)webViewCacheUpdateCounter:(NSString*)url start_counter:(int)start_counter finish_counter:(int)finish_counter;
-(void)webViewCacheDidFinishLoad:(NSString*)url;
-(void)webViewLost:(NSString*)url;
@end

@interface WebViewCache : NSObject<UIWebViewDelegate>
{
    LRUCache *cache;
    int loading_count;
}
+ (WebViewCache*)defaultWebViewCache;
- (BOOL)isLoaded:(NSString*)url;
- (void)addURL:(NSString*) url;
- (void)addURLs:(NSArray*)urls;
- (MyWebView*)getWebView:(NSString*)url;
@property id<WebViewCacheDelegate> delegate;
@end
