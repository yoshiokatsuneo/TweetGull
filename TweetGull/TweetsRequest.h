//
//  TweetsRequest.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetsRequest : NSObject
@property(readonly) NSString *timeline_url;
@property(readonly) NSString *title;
-(NSArray*)tweetArrayFromResponseJSONObj:(id)json_obj;
@end

