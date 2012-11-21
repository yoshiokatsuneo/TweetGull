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

-(void)webViewCacheUpdateProgress:(NSString*)url progress:(double)progress;
-(void)webViewCacheDidFinishLoad:(NSString*)url;
-(void)webViewLost:(NSString*)url;
@end

@interface WebViewCache : NSObject<UIWebViewDelegate,WebViewProgressEstimateChanged>
{
    LRUCache *cache;
    int loading_count;
}
+ (WebViewCache*)defaultWebViewCache;
- (BOOL)isLoaded:(NSString*)url;
- (BOOL)isCached:(NSString*)url; 
- (void)addURL:(NSString*) url;
- (void)addURLs:(NSArray*)urls;
- (MyWebView*)getWebView:(NSString*)url;
@property id<WebViewCacheDelegate> delegate;
@end
