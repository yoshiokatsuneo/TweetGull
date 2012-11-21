//
//  NSJSONSerialization+string.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 9/26/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (string)
+(id)JSONObjectWithString:(NSString*)str options:(NSJSONReadingOptions)options error:(NSError **)error;
@end
