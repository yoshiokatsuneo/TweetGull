//
//  NSJSONSerialization+string.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 9/26/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "NSJSONSerialization+string.h"

@implementation NSJSONSerialization (string)
+(id)JSONObjectWithString:(NSString*)str options:(NSJSONReadingOptions)options error:(NSError **)error
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:options error:error];
    return json;
}
@end
