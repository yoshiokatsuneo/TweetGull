//
//  LRUCache.h
//  LRUCache
//
//  Created by Tsuneo Yoshioka on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRUCache : NSObject
{
    NSMutableArray *array;
    NSMutableDictionary *dic;
}
-(void)setObject:(id)obj forKey:(id)key;
-(id)objectForKey:(id)key;
-(id)init:(int)countLimite;

@property int countLimit;
@end
