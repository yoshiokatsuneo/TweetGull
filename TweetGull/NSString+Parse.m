//
//  NSString+Parse.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Parse.h"

@implementation NSString (Parse)
-(NSArray *)getURLStrings
{
    NSRange search_range = NSMakeRange(0, self.length);
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    while(search_range.length > 0){
        NSRange range = [self rangeOfString:@"http://" options:0 range:search_range];
        if(range.location == NSNotFound){
            range = [self rangeOfString:@"https://" options:0 range:search_range];
        }
        if(range.location == NSNotFound){
            break;
        }
        
        NSCharacterSet *cSetURL = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#%&=?:/-_."];
        int pos;
        for(pos = range.location; pos < self.length; pos++){
            unichar uc = [self characterAtIndex:pos];
            if(![cSetURL characterIsMember:uc]){
                break;
            }
        }
        int end_location = pos;
        // NSCharacterSet *cSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\""];
        // NSRange end_range = [self rangeOfCharacterFromSet:cSet options:0 range:NSMakeRange(range.location, self.length - range.location)];
        // if(end_range.location == NSNotFound){
        //     end_range.location = self.length;
        // }
        NSString *url = [self substringWithRange:NSMakeRange(range.location, end_location - range.location)];
        [urls addObject:url];
        search_range = NSMakeRange(end_location, self.length - end_location);
        
    }
    return urls;
}
-(NSString*)getURLString
{
    NSArray *urls = [self getURLStrings];
    if(urls.count == 0){return nil;}
    return [urls objectAtIndex:0];
}
@end
