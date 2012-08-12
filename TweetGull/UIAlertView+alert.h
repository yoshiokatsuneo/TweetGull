//
//  UIAlertView+alert.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/4/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (alert)
+ (void)alertError:(NSError*)error;
+ (void)alertString:(NSString*)str;
@end
