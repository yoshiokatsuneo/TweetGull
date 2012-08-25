//
//  TweetsRequestFavorites.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/24/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TweetsRequestFavorites.h"

@implementation TweetsRequestFavorites
-(NSString *)title
{
    if(self.user_screen_name){
        return [NSString stringWithFormat:@"\U00002B50\n(%@)", self.user_screen_name];
    }else{
        return @"\U00002B50";
    }
}
-(NSString *)timeline_url
{
    NSString *urlstr = @"http://api.twitter.com/1/favorites.json?count=200&include_entities=1";
    if(self.user_screen_name){
        urlstr = [urlstr stringByAppendingFormat:@"screen_name=%@", self.user_screen_name];
    }
    return urlstr;
}
@end
