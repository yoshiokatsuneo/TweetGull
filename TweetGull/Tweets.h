//
//  Tweets.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweets : NSMutableArray
{
    NSMutableArray *array;
}
- (id)initWithJSONString:(NSString*)json_str;
@end
