//
//  Accounts.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/16/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "Accounts.h"

static Accounts *m_accounts;
@implementation Accounts
+(Accounts*)defaultAccounts
{
    if(m_accounts == nil){
        m_accounts = [[Accounts alloc] init];
    }
    return m_accounts;
}
+(NSString*)currentAccount
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"currentAccount"];
}
+(void)setCurrentAccount:(NSString*)screen_name
{
    [[NSUserDefaults standardUserDefaults] setObject:screen_name forKey:@"currentAccount"];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self load];
        if(dic == nil){
            dic = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}
-(void)load
{
    dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"Accounts"];
}
-(void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"Accounts"];
}
-(NSString*)passwordForAccount:(NSString*)account
{
    return [dic objectForKey:account];
}
-(void)setPassword:(NSString*)password forAccount:(NSString*)account
{
    [dic setObject:password forKey:account];
    [self save];
}
-(void)removeObjectForName:(NSString*)name
{
    [dic removeObjectForKey:name];
    [self save];
}
-(NSArray*)allKeys
{
    return [dic allKeys];
}
-(NSInteger)count
{
    return dic.count;
}
-(NSString*)nameAtIndex:(NSInteger)index
{
    NSArray *keysArray = [self.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return [keysArray objectAtIndex:index];
}


@end
