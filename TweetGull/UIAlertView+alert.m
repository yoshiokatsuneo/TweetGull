//
//  UIAlertView+alert.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/4/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "UIAlertView+alert.h"

@implementation UIAlertView (alert)
+ (void)alertError:(NSError*)error
{
    NSLog(@"%s: error=%@", __func__, error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}
+ (void)alertString:(NSString*)str
{
    NSLog(@"%s: str=%@", __func__, str);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:str message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}
@end
