//
//  Tweet.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"
#import "NSString+Parse.h"

@implementation Tweet
@synthesize retweeted_status;
-(id)initWithDictionary:(NSDictionary *)otherDictionary
{
    self = [super init];
    dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary];
    NSDictionary *retweeted_status_dic = [dic objectForKey:@"retweeted_status"];
    if(retweeted_status_dic){
        retweeted_status = [[Tweet alloc] initWithDictionary:retweeted_status_dic];
    }
    return self;
}
-(NSUInteger)count
{
    return dic.count;
}
-(id)objectForKey:(id)aKey
{
    return [dic objectForKey:aKey];
}
-(NSEnumerator *)keyEnumerator
{
    return [dic keyEnumerator];
}
-(NSDictionary*)origTweet
{
    if(self.retweeted_status){
        return self.retweeted_status;
    }else{
        return self;
    }
}
-(NSString *)text
{    
    NSString *t = [self.origTweet objectForKey:@"text"];
    return t;
}
-(NSArray *)entities_urls
{
    NSArray *urls = [[self.origTweet objectForKey:@"entities"] objectForKey:@"urls"];
    return urls;
    
}
-(NSArray *)entities_media
{
    NSArray *media = [[self.origTweet objectForKey:@"entities"] objectForKey:@"media"];
    if(media){
        sleep(0);
    }
    return media;
}
-(NSArray *)entities_urls_and_media
{
    NSMutableArray *urls = [[NSMutableArray alloc] init ];
    NSArray *entities_urls = self.entities_urls;
    if(entities_urls){
        [urls addObjectsFromArray:entities_urls];
    }
    NSArray *entities_media = self.entities_media;
    if(entities_media){
        [urls addObjectsFromArray:entities_media];
    }
    [urls sortedArrayUsingComparator:^(id obj1, id obj2){
        NSArray *indices1 = [obj1 objectForKey:@"indices"];
        NSArray *indices2 = [obj2 objectForKey:@"indices"];        
        int index_from1 = [[indices1 objectAtIndex:0] intValue];
        int index_from2 = [[indices2 objectAtIndex:0] intValue];
        if(index_from1 > index_from2){
            return NSOrderedDescending;
        }else if(index_from2 > index_from1){
            return NSOrderedAscending;
        }else{
            return NSOrderedSame;
        }
    }];
    return urls;
}
-(NSString*)display_text
{
    
    NSMutableString *t = [NSMutableString stringWithString:self.text];
    NSArray *urls = self.entities_urls_and_media;
    
    for(NSDictionary *url in [urls reverseObjectEnumerator]){
        NSArray *indices = [url objectForKey:@"indices"];
        int index_from = [[indices objectAtIndex:0] intValue];
        int index_to = [[indices objectAtIndex:1] intValue];
        NSString *display_url = [url objectForKey:@"display_url"];
        [t replaceCharactersInRange:NSMakeRange(index_from, index_to - index_from) withString:display_url];
    }
    return t;
}
-(NSDictionary*)orig_user
{
    return [self.origTweet objectForKey:@"user"];
}
-(NSString *)user_name
{
    return [self.orig_user objectForKey:@"name"];
}
-(NSString *)user_screen_name
{
    return [self.orig_user objectForKey:@"screen_name"];
}
-(NSString *)user_profile_image_url
{
    return [self.orig_user objectForKey:@"profile_image_url"];
}

-(NSString *)retweet_user_name
{
    if(self.retweeted_status){
        return [[self objectForKey:@"user"] objectForKey:@"name"];
    }else{
        return nil;
    }
}
-(NSString *)urlString
{
    if(self.entities_urls_and_media && self.entities_urls_and_media.count > 0){
        NSDictionary *url = [self.entities_urls_and_media objectAtIndex:0];
        return [url objectForKey:@"expanded_url"];
    }else{
        return nil;
    }
    // return self.text.getURLString;
}
-(NSString*)instagramURLString
{
    for(NSDictionary *url in self.entities_urls){
        NSString *expanded_url = [url objectForKey:@"expanded_url"];
        NSRange range = [expanded_url rangeOfString:@"http://instagr.am/p/"];
        if(range.location == 0){
            NSString *idstr = [expanded_url substringFromIndex:range.length];
            NSCharacterSet *cSetURL = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"];
            int pos;
            for(pos = 0; pos < idstr.length; pos++){
                unichar uc = [idstr characterAtIndex:pos];
                if(![cSetURL characterIsMember:uc]){
                    break;
                }
            }
            idstr = [idstr substringToIndex:pos];
            NSString *url =[@"instagram://media?id=" stringByAppendingString:idstr];
            return url;
        }
    }
    return nil;
}
-(NSString*)twitpicURLString
{
    for(NSDictionary *url in self.entities_urls){
        NSString *expanded_url = [url objectForKey:@"expanded_url"];
        NSRange range = [expanded_url rangeOfString:@"http://twitpic.com/"];
        if(range.location == 0){
            NSString *idstr = [expanded_url substringFromIndex:range.length];
            NSString *url =[NSString stringWithFormat:@"http://twitpic.com/show/large/%@" ,idstr];
            return url;
        }
    }
    return nil;
}

-(NSString*)mediaURLString
{
    if(self.entities_media && self.entities_media.count > 0){
        NSDictionary *media = [self.entities_media objectAtIndex:0];
        return [media objectForKey:@"media_url"];
    }else{
        NSString *url;
        url = self.instagramURLString;
        if(url){
            return url;
        }
        url = [self twitpicURLString];
        if(url){
            return url;
        }
        return nil;
    }
}
-(NSString*)linkURLString
{
    if(self.entities_urls && self.entities_urls.count > 0){
        NSDictionary *url = [self.entities_urls objectAtIndex:0];
        return [url objectForKey:@"expanded_url"];
    }else{
        return nil;
    }
}
-(NSDate *)created_at_date
{
    NSString * str = [self.origTweet objectForKey:@"created_at"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    // "Thu Jul 26 09:48:16 +0000 2012"
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    NSDate *date = [dateFormatter dateFromString:str];
    return date;
}
-(NSString*)created_at_str
{
    NSDate *date = [self created_at_date];
    NSString *str = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    return str;
}
@end
