//
//  User.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 10/10/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSMutableDictionary
{
    NSMutableDictionary *dic;
}
@property(readonly) NSString *id_str;
@property(readonly) NSString *name;
@property(readonly) NSString *screen_name;
@property(readonly) NSString *profile_image_url;
@end

