//
//  MyWebView.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWebView : UIWebView<UIWebViewDelegate>
{
    id<UIWebViewDelegate> next_delegate;
}
@property int startLoadCount;
@property int finishLoadCount;
@property UIImage *thumbnailImageView;
@property(readonly) int loadCount;
@property NSString *startURL;
-(void)delayedCaptureThumbNail;
-(void)cancelCaptureThumbNail;
@end
