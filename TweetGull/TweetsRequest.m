//
//  TweetsRequest.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TweetsRequest.h"

@implementation TweetsRequest
-(NSArray*)tweetArrayFromResponseJSONObj:(id)json_obj
{
    if([json_obj isKindOfClass:[NSArray class]]){
        return json_obj;
    }else{
        return nil;
    }
}

@end
