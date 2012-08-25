//
//  Tweet.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"
#import "NSString+Parse.h"
#import "google-toolbox-for-mac/GTMNSString+HTML.h"

@implementation Tweet
@synthesize retweeted_status;
-(id)initWithDictionary:(NSDictionary *)otherDictionary
{
    self = [super init];
    [self setDictionary:otherDictionary];
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
-(void)setObject:(id)anObject forKey:(id)aKey
{
    [dic setObject:anObject forKey:aKey];
}
-(void)removeObjectForKey:(id)aKey
{
    [dic removeObjectForKey:aKey];
}
-(void)setDictionary:(NSDictionary*)otherDictionary
{
    dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary];
    NSDictionary *retweeted_status_dic = [dic objectForKey:@"retweeted_status"];
    if(retweeted_status_dic){
        retweeted_status = [[Tweet alloc] initWithDictionary:retweeted_status_dic];
    }
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
-(NSString *)id_str
{
    NSString *t = [self.origTweet objectForKey:@"id_str"];
    // NSString *t = [self objectForKey:@"id_str"];
    return t;
}
-(BOOL)retweeted
{
    id obj = [self.origTweet objectForKey:@"retweeted"];
    NSNumber *val = obj;
    return [val boolValue];
}
-(void)setRetweeted:(BOOL)retweeted
{
    NSNumber *val = [NSNumber numberWithBool:retweeted];
    [self.origTweet setValue:val forKey:@"retweeted"];
}
-(BOOL)favorited
{
    id obj = [self.origTweet objectForKey:@"favorited"];
    NSNumber *val = obj;
    return [val boolValue];
}
-(void)setFavorited:(BOOL)favorited
{
    NSNumber *val = [NSNumber numberWithBool:favorited];
    [self.origTweet setValue:val forKey:@"favorited"];
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
-(NSString*)display_text_without_unescape_html
{
    
    NSMutableString *t = [NSMutableString stringWithString:self.text];
    NSArray *urls = self.entities_urls_and_media;
    
    for(NSDictionary *url in [urls reverseObjectEnumerator]){
        NSArray *indices = [url objectForKey:@"indices"];
        int index_from = [[indices objectAtIndex:0] intValue];
        int index_to = [[indices objectAtIndex:1] intValue];
        NSString *display_url = [url objectForKey:@"display_url"];
        if(display_url){
            [t replaceCharactersInRange:NSMakeRange(index_from, index_to - index_from) withString:display_url];
        }
    }
    return t;
}
-(NSString*)display_text
{
    NSString *t = [self display_text_without_unescape_html];
    NSString *unescape_str = [t gtm_stringByUnescapingFromHTML];
    return unescape_str;
}
-(NSString*)display_html
{
    NSString *t = [self display_text_without_unescape_html];
    NSRange search_range = NSMakeRange(0, t.length);
    while (search_range.length > 0){
        NSRange range = [t rangeOfString:@"@" options:0 range:search_range];
        if(range.location == NSNotFound){
            break;
        }
        if(!(range.location == 0 || [t characterAtIndex:(range.location - 1)] == ' ')){
            search_range = NSMakeRange(range.location+1, t.length - (range.location+1));
            continue;
        }
        NSCharacterSet *screenNameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"];
        if(![screenNameCharacterSet characterIsMember:[t characterAtIndex:range.location+1]]){
            search_range = NSMakeRange(range.location+1, t.length - (range.location+1));
            continue;
        }
        int pos = range.location + 1;
        while(pos<t.length){
            unichar c = [t characterAtIndex:pos];
            if(![screenNameCharacterSet characterIsMember:c]){
                break;
            }
            pos++;
        }
        NSRange range2 = NSMakeRange(range.location+1, pos - (range.location+1));
        
        // NSRange range2 = [t rangeOfCharacterFromSet:screenNameCharacterSet options:0 range:NSMakeRange(range.location+1, t.length - (range.location+1))];
        NSString *screen_name2 = [t substringWithRange:range2];
        NSString *linkString = [NSString stringWithFormat:@"<a href=\"http://screen_name:%@\"  style=\"text-decoration:none\">@%@</a>", screen_name2, screen_name2];
        
        NSString *t2 = [NSString stringWithFormat:@"%@%@%@", [t substringToIndex:range.location], linkString, [t substringFromIndex:range2.location + range2.length]];
        
        t = t2;
        search_range = NSMakeRange(range.location + linkString.length, t2.length - (range.location + linkString.length));
    }
    
    return t;
}


-(NSDictionary*)orig_user
{
    return [self.origTweet objectForKey:@"user"];
}
-(NSString *)user_name
{
    NSString *str = [self objectForKey:@"from_user_name"];
    if(str){
        /* search API */
        return str;
    }
    return [self.orig_user objectForKey:@"name"];
}
-(NSString *)user_screen_name
{
    NSString *str = [self objectForKey:@"from_user"];
    if(str){
        /* search API */
        return str;
    }
    return [self.orig_user objectForKey:@"screen_name"];
}
-(NSString *)user_profile_image_url
{
    NSString *str = [self objectForKey:@"profile_image_url"];
    if(str){
        /* search API */
        return str;
    }
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
-(NSString *)retweet_screen_name
{
    if(self.retweeted_status){
        return [[self objectForKey:@"user"] objectForKey:@"screen_name"];
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
        if(!expanded_url || (NSNull*)expanded_url == [NSNull null]){
            continue;
        }
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
        if(expanded_url == nil || (NSNull*)expanded_url == [NSNull null]){
            continue;
        }
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
        id expanded_url = [url objectForKey:@"expanded_url"];
        if(expanded_url == [NSNull null]){
            return nil;
        }
        return expanded_url;
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
    if(date == nil){
        /* search API */
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
        date = [dateFormatter dateFromString:str];
    }
    return date;
}
-(NSString*)created_at_str
{
    NSDate *date = [self created_at_date];
    NSString *str = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    return str;
}
@end
