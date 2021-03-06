//
//  WebViewCache.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewCache.h"
#import <QuartzCore/QuartzCore.h>
#import "NetworkActivityIndicator.h"

@interface CacheWebViewItem : NSObject<NSDiscardableContent>
{
    BOOL discarded;
@public
    MyWebView *webView;
}
@end


@implementation CacheWebViewItem

- (id)init:(NSString*)url;
{
    NSLog(@"%s begin. url=%@", __func__, url);
    self = [super init];
    if (self) {
        webView = [[MyWebView alloc] initWithFrame:CGRectMake(0, 101, 320, 300)];
        webView.scalesPageToFit = TRUE;
        webView.startURL = url;
        NSURL *aURL = [NSURL URLWithString:url];
        NSURLRequest *aURLRequest = [NSURLRequest requestWithURL:aURL];
#if 0
        NSURL *confirm_url = [[NSBundle mainBundle] URLForResource:@"confirm" withExtension:@"html"];
        NSString *confirm_urlstr = confirm_url.absoluteString;
        // NSString *confirm_func = [NSString stringWithFormat:@"window.confirm=function(msg){window.showModalDialog('%@', this, \"dialogWidth=800px; dialogHeight=480px;\"); return false;}", confirm_urlstr];
        NSString *confirm_func = [NSString stringWithFormat:@"window.confirm=function(msg){alert('zzzzzzz');}"];
#endif
        webView.thumbnailMode = YES;
        [webView loadRequest:aURLRequest];
    }
    return self;
}
-(void)discardContentIfPossible
{
    NSLog(@"%s begin: url=%@", __func__, webView.startURL);
    [webView stopLoading];
    discarded = TRUE;
}
-(BOOL)beginContentAccess
{
    NSLog(@"%s begin: url=%@", __func__, webView.startURL);
    return TRUE;
}
-(void)endContentAccess
{
    NSLog(@"%s begin: url=%@", __func__, webView.startURL);
    ;
}
-(BOOL)isContentDiscarded
{
    NSLog(@"%s begin: url=%@", __func__, webView.startURL);
    return discarded;
}
- (void)dealloc
{
    [webView stopLoading];
    [webView cancelCaptureThumbNail];
    if(webView.superview){
        [webView removeFromSuperview];
    }
    NSLog(@"%s begin: url=%@", __func__, webView.startURL);
}
@end

@implementation WebViewCache
@synthesize delegate;

static WebViewCache *webViewCache = nil;
+ (WebViewCache*)defaultWebViewCache
{
    if(!webViewCache){
        webViewCache = [[WebViewCache alloc] init];
    }
    return webViewCache;
}
- (id)init
{
    self = [super init];
    if (self) {
        int cachesize = 0;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            /* iPad */
            cachesize = 10;
        }else{
            /* iPhone */
            if(height > 500){
                /* iPhone5: 568 */
                cachesize = 6;
            }else{
                /* iPhone4: 480 */
                cachesize = 5;
            }
        }
        
        cache = [[LRUCache  alloc] init:cachesize];
        // cache.countLimit = 10;
        // cache.evictsObjectsWithDiscardedContent = TRUE;
        loading_count = 0;
    }
    return self;
}
- (BOOL)isLoaded:(NSString*)url
{
    CacheWebViewItem * item = [cache objectForKey:url];
    if(!item){return NO;}
    MyWebView *webView = item->webView;
    BOOL loading = webView.loading;
    return !loading;
}
-(BOOL)isCached:(NSString*)url
{
    CacheWebViewItem * item = [cache objectForKey:url];
    return (item != nil);
}
- (void)addURL:(NSString*) url
{
    NSLog(@"%s: url=%@", __func__, url);
    CacheWebViewItem *item = [cache objectForKey:url];
    if(item){
        [cache setObject:item forKey:url]; /* to mark the item is recently used */
        return;
    }
    
    
    item = [[CacheWebViewItem alloc] init:url];
    item->webView.delegate = self;
    item->webView.scrollView.scrollsToTop = NO;
    [cache setObject:item forKey:url];
}
- (void)addURLs:(NSArray*)urls
{
    int num = MIN(urls.count, cache.countLimit);
    for(int i=0;i<num;i++){
        [self addURL:[urls objectAtIndex:i]];
    }
}
- (MyWebView*)getWebView:(NSString*)url
{
    if(url == nil){return nil;}
    [self addURL:url];
    CacheWebViewItem * item = [cache objectForKey:url];
    return item->webView;
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    MyWebView *myWebView = (MyWebView*)webView;
    // NSLog(@"%s: myWebView=%p:%@", __func__, myWebView, myWebView);
    NSLog(@"%s: request URL=%@, orig_url=%@", __func__, [request URL], ((MyWebView*)webView).startURL);
    NSArray *stopSchemes = [NSArray arrayWithObjects:@"itms", @"itmss", @"itms-appss", nil];
    if(myWebView.thumbnailMode && [stopSchemes indexOfObject:request.URL.scheme]!=NSNotFound){
        myWebView.pendingRequest = request;
        return FALSE;
    }
    return TRUE;
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    MyWebView *myWebView = (MyWebView*) webView;
    NSString * url = myWebView.startURL;
    
    // [delegate webViewCacheUpdateProgress:url progress:(1.0*myWebView.finishLoadCount)/(1.0*myWebView.startLoadCount)];
    
    [[NetworkActivityIndicator sharedNetworkActivityIndicator] increment];
    // if(loading_count == 0){
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //}
    loading_count ++;
    NSLog(@"%s: url=%@, loading_count=%d, counter=%d", __func__, url, loading_count, myWebView.loadCount);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    MyWebView *myWebView = (MyWebView*)webView;
    loading_count --;
    //if(loading_count == 0){
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //}
    [[NetworkActivityIndicator sharedNetworkActivityIndicator] decrement];
    
    // if(webView.loading){return;}
    NSString *url = myWebView.startURL;

    // [delegate webViewCacheUpdateProgress:url progress:(1.0*myWebView.finishLoadCount)/(1.0*myWebView.startLoadCount)];
    
    if(myWebView.loadCount == 0){
        [delegate webViewCacheDidFinishLoad:url];
    }

    [myWebView delayedCaptureThumbNail];
    
    NSLog(@"%s: webView=%p, loading=%d, url=%@, loading_count=%d, counter=%d", __func__, (__bridge void*)webView, webView.loading, url, loading_count, myWebView.loadCount);
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%s: url=%@, error=%@", __func__, ((MyWebView*)webView).startURL, error);
}
-(void)webView:(MyWebView *)webView progressEstimatedChanged:(double)progress
{
    MyWebView *myWebView = (MyWebView*)webView;
    NSString *url = myWebView.startURL;
    [delegate webViewCacheUpdateProgress:url progress:progress];
    NSLog(@"%s: url=%@, progress=%lf", __func__, url, progress);
}
@end

