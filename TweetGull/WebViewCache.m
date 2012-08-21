//
//  WebViewCache.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewCache.h"


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
        NSString *confirm_func = [NSString stringWithFormat:@"window.tweetgull_orig_confirm = window.confirm; window.confirm=function(msg){return false;}; window.tweetgull_orig_alert = window.alert; window.alert=nil"];
        [webView stringByEvaluatingJavaScriptFromString:confirm_func];
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
        cache = [[LRUCache  alloc] init:10];
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
- (void)addURL:(NSString*) url
{
    NSLog(@"%s: url=%@", __func__, url);
    CacheWebViewItem *item = [cache objectForKey:url];
    if(item){return;}    
    
    
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
    
    NSLog(@"%s: request URL=%@, orig_url=%@", __func__, [request URL], ((MyWebView*)webView).startURL);
    return TRUE;
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    MyWebView *myWebView = (MyWebView*) webView;
    NSString * url = myWebView.startURL;
    [delegate webViewCacheUpdateCounter:url start_counter:myWebView.startLoadCount finish_counter:myWebView.finishLoadCount];
    
    if(loading_count == 0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    loading_count ++;
    NSLog(@"%s: url=%@, loading_count=%d, counter=%d", __func__, url, loading_count, myWebView.loadCount);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    MyWebView *myWebView = (MyWebView*)webView;
    loading_count --;
    if(loading_count == 0){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    // if(webView.loading){return;}
    NSString *url = myWebView.startURL;

    [delegate webViewCacheUpdateCounter:url start_counter:myWebView.startLoadCount finish_counter:myWebView.finishLoadCount];    
    
    if(myWebView.loadCount == 0){
        [delegate webViewCacheDidFinishLoad:url];
    }

    NSLog(@"%s: webView=%p, loading=%d, url=%@, loading_count=%d, counter=%d", __func__, (__bridge void*)webView, webView.loading, url, loading_count, myWebView.loadCount);
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%s: url=%@, error=%@", __func__, ((MyWebView*)webView).startURL, error);
}
@end

