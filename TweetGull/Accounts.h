//
//  Accounts.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/16/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Accounts : NSObject
{
    NSMutableDictionary *dic;
}
+(Accounts*)defaultAccounts;
+(NSString*)currentAccount;
+(void)setCurrentAccount:(NSString*)screen_name;
-(void)load;
-(void)save;
-(NSString*)passwordForAccount:(NSString*)account;
-(void)setPassword:(NSString*)password forAccount:(NSString*)account;
-(NSString*)nameAtIndex:(NSInteger)index;
-(void)removeObjectForName:(NSString*)name;

@property(readonly) NSArray *allKeys;
@property(readonly) NSInteger count;

@end
