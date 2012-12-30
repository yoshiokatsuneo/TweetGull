//
//  MyWebView.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewHeaders/WebView.h"
#import "WebViewHeaders/UIWebDocumentView.h"

@class MyWebView;

@protocol WebViewProgressEstimateChanged <NSObject>
-(void)webView:(MyWebView*) webView progressEstimatedChanged:(double)progress;
@end

@interface MyWebView : UIWebView<UIWebViewDelegate>
{
    id<UIWebViewDelegate,WebViewProgressEstimateChanged> next_delegate;
}
@property int startLoadCount;
@property int finishLoadCount;
@property UIImage *thumbnailImage;
@property(readonly) int loadCount;
@property NSString *startURL;
@property(nonatomic) BOOL thumbnailMode;
@property NSURLRequest *pendingRequest;
@property(readonly) double estimatedProgress;
-(void)delayedCaptureThumbNail;
-(void)cancelCaptureThumbNail;
@end
