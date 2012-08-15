//
//  Tweet.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSMutableDictionary
{
    NSMutableDictionary *dic;
}
@property(readonly) NSString *text;
@property(readonly) NSString *htmlText;
@property(readonly) NSString *id_str;
@property(readwrite) BOOL retweeted;
@property(readwrite) BOOL favorited;
@property(readonly) NSString *display_text;
@property(readonly) NSString *display_html;
@property(readonly) NSString *user_name;
@property(readonly) NSString *user_screen_name;
@property(readonly) NSString *user_profile_image_url;
@property(readonly) NSString *urlString;
@property(readonly) NSString *mediaURLString;
@property(readonly) NSString *linkURLString;
@property(readonly) NSString *instagramURLString;
@property(readonly) NSString *retweet_user_name;
@property(readonly) NSString *retweet_screen_name;
@property(readonly) NSDate   *created_at_date;
@property(readonly) NSString *created_at_str;
@property(readonly) NSArray *entities_urls_and_media;
@property(readonly) NSArray *entities_urls;
@property(readonly) NSArray *entities_media;
@property(readonly) NSDictionary *orig_user;
@property(readonly) Tweet *retweeted_status;
@property(readonly) Tweet *origTweet;

-(void)setDictionary:(NSDictionary*)otherDictionary;
@end
