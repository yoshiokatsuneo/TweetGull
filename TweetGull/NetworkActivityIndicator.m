//
//  NetworkActivityIndicator.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 11/28/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "NetworkActivityIndicator.h"

@interface NetworkActivityIndicator ()
{
    int counter;
}
@end

@implementation NetworkActivityIndicator
static NetworkActivityIndicator *sharedNetworkActivityIndicator_ = nil;
+(NetworkActivityIndicator*)sharedNetworkActivityIndicator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetworkActivityIndicator_ = [[NetworkActivityIndicator alloc] init];
    });
    return sharedNetworkActivityIndicator_;
}
-(void)increment
{
    @synchronized(self){
        if(counter == 0){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
        counter++;
    }
}
-(void)decrement
{
    @synchronized(self){
        counter--;
        if(counter == 0){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
}
@end
