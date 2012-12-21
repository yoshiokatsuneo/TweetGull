//
//  NetworkActivityIndicator.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 11/28/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkActivityIndicator : NSObject
+(NetworkActivityIndicator*)sharedNetworkActivityIndicator;
-(void)increment;
-(void)decrement;
@end

