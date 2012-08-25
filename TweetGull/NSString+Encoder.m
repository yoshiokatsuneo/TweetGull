//
//  NSString+Encoder.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "NSString+Encoder.h"

@implementation NSString (Encoder)
- (NSString*)percentEncodeString
{
    return (__bridge_transfer NSString*) CFURLCreateStringByAddingPercentEscapes(NULL,  (__bridge CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
}

@end
