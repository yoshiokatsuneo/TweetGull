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
#import "NSString+Encoder.h"

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
    
    NSMutableString *t = [NSMutableString stringWithString:self.text];
    NSArray *urls = self.entities_urls_and_media;
    NSArray *user_mentions = self.origTweet[@"entities"][@"user_mentions"];
    NSArray *hashtags = self.origTweet[@"entities"][@"hashtags"];
    NSMutableArray *entities_contents = [[NSMutableArray alloc] init];
    [entities_contents addObjectsFromArray:urls];
    [entities_contents addObjectsFromArray:user_mentions];
    [entities_contents addObjectsFromArray:hashtags];
    [entities_contents sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2){
        NSArray *indices1 = obj1[@"indices"];
        NSArray *indices2 = obj2[@"indices"];
        id indices1_1 = indices1[0];
        id indices2_1 = indices2[0];
        return [indices1_1 compare:indices2_1];
    }];
    
    for(NSDictionary *item in entities_contents.reverseObjectEnumerator){
        NSArray *indices = [item objectForKey:@"indices"];
        int index_from = [[indices objectAtIndex:0] intValue];
        int index_to = [[indices objectAtIndex:1] intValue];
        NSString *display_url = [item objectForKey:@"display_url"];
        NSString *media_url = [item objectForKey:@"media_url"];
        NSString *expanded_url = [item objectForKey:@"expanded_url"];
        NSString *id_str = [item objectForKey:@"id_str"];
        NSString *hashtag_text = [item objectForKey:@"text"];
        NSString *replaced_str = nil;
        if(media_url){
            replaced_str = [NSString stringWithFormat:@"<a href=\"http://media_url/%@\" style=\"text-decoration:none\">%@</a>", [media_url percentEncodeString], display_url];
        }else if(display_url){
            replaced_str = [NSString stringWithFormat:@"<a href=\"http://url/%@\" style=\"text-decoration:none\">%@</a>", [expanded_url percentEncodeString], display_url];
        }else if(id_str){
            NSDictionary *user_dic = @{@"id_str":item[@"id_str"], @"screen_name":item[@"screen_name"]};
            NSError *error = nil;
            NSData *user_json_data = [NSJSONSerialization dataWithJSONObject:user_dic options:0 error:&error];
            NSString *user_json_str = [[NSString alloc] initWithData:user_json_data encoding:NSUTF8StringEncoding];
            
            NSString *linkString = [NSString stringWithFormat:@"<a href=\"http://tweet_user/%@\"  style=\"text-decoration:none\">@%@</a>", [user_json_str percentEncodeString], item[@"screen_name"]];
            replaced_str = linkString;
        }else if(hashtag_text){
            replaced_str = [NSString stringWithFormat:@"<a href=\"http://hashtag/%@\" style=\"text-decoration:none\">#%@</a>", [hashtag_text percentEncodeString], hashtag_text];
        }
        if(replaced_str){
            [t replaceCharactersInRange:NSMakeRange(index_from, index_to - index_from) withString:replaced_str];
        }
    }
    return t;
}



-(User*)orig_user
{
    NSDictionary *dic2 = [self.origTweet objectForKey:@"user"];
    User *user = [[User alloc] initWithDictionary:dic2];
    return user;
}
-(User*)retweet_user
{
    if(self.retweeted_status){
        NSDictionary *userdic = self[@"user"];
        User *user = [[User alloc] initWithDictionary:userdic];
        return user;
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
            NSCharacterSet *cSetURL = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"];
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
