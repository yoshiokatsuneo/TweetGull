//
//  AppDelegate.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/4/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "UIAlertView+alert.h"
#import "NetworkActivityIndicator.h"
#import "NSString+Encoder.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *prev_version = [defaults objectForKey:@"installedVersion"];
    NSString *prev_shortVersion = [defaults objectForKey:@"installedShortVersion"];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (! ([prev_version isEqual:version] && [prev_shortVersion isEqual:shortVersion])){
        [defaults removeObjectForKey:@"askedToTweetAboutInstallation"];
    }
    [defaults setObject:version forKey:@"installedVersion"];
    [defaults setObject:shortVersion forKey:@"installedShortVersion"];
    // [defaults synchronize];
    
    sleep(0);
#if 0
    /* notification registration */
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
#endif
    
#if 0
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
#if 0
        UIStoryboard *storyboard_iphone = [UIStoryboard storyboardWithName:@"MainStoryboard_iphone" bundle:nil];

        MasterViewController *masterViewController_iphone = [storyboard_iphone instantiateInitialViewController];
        DetailViewController *detailViewController_iphone = [storyboard_iphone instantiateViewControllerWithIdentifier:@"MyDetailViewController"];
        UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
        splitViewController.viewControllers = [NSArray arrayWithObjects:masterViewController_iphone, detailViewController_iphone, nil];
#endif

        
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
        MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    } else {
#endif
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
#if 0
    }
#endif
    NSLog(@"memoryCapacity=%u, diskCapacity=%u", [NSURLCache sharedURLCache].memoryCapacity, [NSURLCache sharedURLCache].diskCapacity);
    [NSURLCache sharedURLCache].memoryCapacity = 10000000;
    NSLog(@"memoryCapacity=%u, diskCapacity=%u", [NSURLCache sharedURLCache].memoryCapacity, [NSURLCache sharedURLCache].diskCapacity);
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TweetGull" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TweetGull.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"openURL:%@", url);
    return NO;
}

- (void)sendProvicerDeviceToken:(NSString*)token oauth_token:(NSString*)oauth_token oauth_token_secret:(NSString*)oauth_token_secret serviceProvider:(NSString*)serviceProvider user_id:(NSString*)user_id screen_name:(NSString*)screen_name
{
    NSString *datastr = [NSString stringWithFormat:@"token[device_token]=%@&token[oauth_token]=%@&token[oauth_token_secret]=%@&token[service_provider]=%@&token[user_id]=%@&token[screen_name]=%@", token.percentEncodeString, oauth_token.percentEncodeString, oauth_token_secret.percentEncodeString, serviceProvider.percentEncodeString, user_id.percentEncodeString, screen_name.percentEncodeString];
    NSLog(@"datastr=%@", datastr);
    NSData *data = [datastr dataUsingEncoding:NSUTF8StringEncoding];
    // [data appendData:token]; // should be hex string ???
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://tweetgullprovider.herokuapp.com/tokens"]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [[NetworkActivityIndicator sharedNetworkActivityIndicator] increment];
    // NSData *body = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response_, NSData *data, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)response_;
        [[NetworkActivityIndicator sharedNetworkActivityIndicator] decrement];
        NSLog(@"error=%@", error);
        if(error){
            [UIAlertView alertError:error];
            return;
        }
        NSLog(@"body=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if(response.statusCode != 200){
            [UIAlertView alertString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            return;
        }

    }];

    
}

- (void)sendProvicerOauth_token:(NSString*)oauth_token oauth_token_secret:(NSString*)oauth_token_secret serviceProvider:(NSString*)serviceProvider user_id:(NSString*)user_id screen_name:(NSString*)screen_name
{
    [self sendProvicerDeviceToken:self.deviceToken oauth_token:oauth_token oauth_token_secret:oauth_token_secret serviceProvider:serviceProvider user_id:user_id screen_name:screen_name];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    NSLog(@"deviceToken: %@", hexToken);
    self.deviceToken = hexToken;
    // [self sendProvicerDeviceToken:hexToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:error=[%@]", error);
    [UIAlertView alertError:error];
}
@end
