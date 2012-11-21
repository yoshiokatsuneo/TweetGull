//
//  MyWebView.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyWebView.h"
#import <QuartzCore/QuartzCore.h>
#import "WebViewHeaders/WebView.h"
#import "WebViewHeaders/UIWebDocumentView.h"
NSString *WebViewProgressStartedNotification =          @"WebProgressStartedNotification";
NSString *WebViewProgressEstimateChangedNotification =  @"WebProgressEstimateChangedNotification";
NSString *WebViewProgressFinishedNotification =         @"WebProgressFinishedNotification";

@implementation MyWebView
@synthesize startLoadCount;
@synthesize finishLoadCount;
@synthesize startURL;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        
        
        /*
         get progress notification from WebView in UIWebDocumentView in UIWebView
         Ref:
           iPhone UIWebView Estimated Progress
             http://winxblog.com/2009/02/iphone-uiwebview-estimated-progress/
           MacRumors - Following website, but code isn't working (tracking progress of a WebView)
             http://forums.macrumors.com/showthread.php?t=1231568
           Mac OS X Cocoa(not iOS Cocoa-Touch) WebView Class Reference
             http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/WebKit/Classes/WebView_Class/Reference/Reference.html
         */
        UIWebDocumentView *documentView = [self _documentView];
        WebView *coreWebView = [documentView webView];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(progressEstimateChanged:) name:WebViewProgressStartedNotification object:coreWebView];
        [center addObserver:self selector:@selector(progressEstimateChanged:) name:WebViewProgressEstimateChangedNotification object:coreWebView];
        [center addObserver:self selector:@selector(progressEstimateChanged:) name:WebViewProgressFinishedNotification object:coreWebView];
    }
    return self;
}
-(void)loadRequest:(NSURLRequest *)request
{
    startURL = request.URL.description;
    NSLog(@"%s: url=%@\n",__func__, request.URL);
    [super loadRequest:request];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setDelegate:(id<UIWebViewDelegate>)delegate
{
    if(delegate == self){
        [super setDelegate:delegate];
    }else{
        next_delegate = (id<UIWebViewDelegate, WebViewProgressEstimateChanged>)delegate;
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [next_delegate webView:webView didFailLoadWithError:error];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return [next_delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.startLoadCount ++;
    [next_delegate webViewDidStartLoad:webView];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.finishLoadCount ++;
    [next_delegate webViewDidFinishLoad:webView];
    
    NSNotification *notification = [NSNotification notificationWithName:@"observerWebViewDidFinishLoad" object:self];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotification:notification];
}
-(void)progressEstimateChanged:(NSNotification*)notification
{
    WebView *coreWebView = [notification object];
    double progress = [coreWebView estimatedProgress];
    if(progress==0){progress = 1.0;}
    [next_delegate webView:self progressEstimatedChanged:progress];
}
-(int)loadCount
{
    return self.startLoadCount - self.finishLoadCount;
}

-(void)captureThumbNail:(id)dummy
{
    if(self.layer){
        if(self.superview){
            // UIGraphicsBeginImageContext(CGSizeMake(80, 103));
            UIGraphicsBeginImageContext(CGSizeMake(80, 103));
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
            self.thumbnailImageView = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
}
-(void)delayedCaptureThumbNail
{
    [self cancelCaptureThumbNail];
    [self performSelector:@selector(captureThumbNail:) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(captureThumbNail:) withObject:nil afterDelay:5.0];
}
-(void)cancelCaptureThumbNail
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(captureThumbNail:) object:nil];
}
-(void)dealloc
{
    sleep(0);
}
@end


