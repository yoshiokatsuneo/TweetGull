//
//  Users.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 9/26/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Users : NSArray
{
    NSArray *array;
}
-(id)initWithJSONArray:(NSArray *)json_array;
@end
