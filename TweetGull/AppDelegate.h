//
//  AppDelegate.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/4/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property NSString *deviceToken;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)sendProvicerOauth_token:(NSString*)oauth_token oauth_token_secret:(NSString*)oauth_token_secret serviceProvider:(NSString*)serviceProvider user_id:(NSString*)user_id screen_name:(NSString*)screen_name;

@end
