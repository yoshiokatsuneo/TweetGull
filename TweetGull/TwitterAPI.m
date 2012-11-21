//
//  TwitterAPI.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/7/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "TwitterAPI.h"
#import "UIAlertView+alert.h"
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"
#import "DETweetComposeViewController/DETweetComposeViewController.h"
#import "Tweets.h"
#import "TweetsRequest.h"
#import "Users.h"
#import "NSJSONSerialization+string.h"

// static NSString *const kTwitterKeychainItemName = @"TwitterTest1";
static NSString *const kTwitterKeychainItemName = @""; /* Not to save Keychain from GTMOAuth */


static TwitterAPI *m_current = nil;

@interface TwitterAPI ()
{
    GTMOAuthAuthentication *auth;
    void (^signInCallback)(void);
    UIViewController *signInViewController;
}
@end

@implementation TwitterAPI
+(TwitterAPI*)defaultTwitterAPI
{
    if(m_current == nil){
        m_current = [[TwitterAPI alloc] init];
    }
    return m_current;
}
- (NSString *)screen_name
{
    return auth.screenName;
}


- (GTMOAuthAuthentication*)getNewAuth
{
    NSString *myConsumerKey = @"1Tfg491UZho03mDZdhpkuA";
    NSString *myConsumerSecret = @"XTUnvinSXim4NXTVNY8sqwQbGXhkLDV5qtIev4Drt0";
    
    GTMOAuthAuthentication *newauth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1 consumerKey:myConsumerKey privateKey:myConsumerSecret];
    [newauth setServiceProvider:@"Twitter"];
    return newauth;
    
}

-(void)viewController:(GTMOAuthViewControllerTouch*)viewController finishedWithAuth:(GTMOAuthAuthentication*)auth2 error:(NSError*)error
{
    if(error == nil){
        NSLog(@"login success");
    }else{
        NSLog(@"login failed");
        [UIAlertView alertError:error];
        // [self dismissModalViewControllerAnimated:YES];
        [viewController dismissViewControllerAnimated:YES completion:nil];
        // [signInViewController.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSLog(@"auth=%@", auth);
    NSLog(@"auth2=%@", auth2);
    auth = auth2;
    //[self dismissModalViewControllerAnimated:YES];
    [viewController dismissViewControllerAnimated:YES completion:nil];
#if 0
    [signInViewController.navigationController popViewControllerAnimated:YES];
#endif
    signInCallback();
}
- (void)signInReal:(UIViewController*)viewController callback:(void (^)(void))callback
{
    signInCallback = callback;
    signInViewController = viewController;

    NSURL *requestURL = [NSURL URLWithString:@"http://twitter.com/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"http://twitter.com/oauth/access_token"];
    NSURL *authrizeURL = [NSURL URLWithString:@"http://twitter.com/oauth/authorize"];
    NSString *scope = @"http://api.twitter.com";
    GTMOAuthAuthentication *auth2 = [self getNewAuth];
    
    [auth2 setCallback:@"http://www.example.com/OAuthCallback"];
    
    GTMOAuthViewControllerTouch *authViewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope language:nil requestTokenURL:requestURL authorizeTokenURL:authrizeURL accessTokenURL:accessURL authentication:auth2 appServiceName:kTwitterKeychainItemName delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    authViewController.browserCookiesURL = [NSURL URLWithString:@"http://api.twitter.com/"];
    [viewController presentViewController:authViewController animated:YES completion:nil];
#if 0
    UINavigationController *navigationController = viewController.navigationController;
    [navigationController pushViewController:authViewController animated:YES];
#endif
}
- (void)signIn:(UIViewController*)viewController callback:(void (^)(void))callback
{
    if(auth){
        callback();
        return;
    }
    GTMOAuthAuthentication *auth2 = [self getNewAuth];
    BOOL didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:kTwitterKeychainItemName authentication:auth2];
    if(!didAuth){
        [self signInReal:viewController callback:callback];
    }else{
        auth = auth2;
        callback();
    }
}


-(void)composeTweet:(UIViewController*)viewController text:(NSString*)text in_reply_to_status_id_str:(NSString*)in_reply_to_status_id_str
{
    NSString *oauth_token = auth.token;
    NSString *oauth_token_secret = auth.tokenSecret;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:oauth_token forKey:@"detwitter_oauth_token"];
    [defaults setObject:oauth_token_secret forKey:@"detwitter_oauth_token_secret"];
    [defaults setBool:YES forKey:@"detwitter_oauth_token_authorized"];
    
    DETweetComposeViewController *tcvc = [[DETweetComposeViewController alloc] init];
    tcvc.in_reply_to_status_id_str = in_reply_to_status_id_str;
    
    [tcvc setInitialText:text];
    tcvc.completionHandler = ^(DETweetComposeViewControllerResult result){
        switch(result){
            case DETweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter result: Cancelled");
                break;
            case DETweetComposeViewControllerResultDone:
                NSLog(@"Twitter result: Sent");
                break;
        }
        [viewController dismissModalViewControllerAnimated:YES];
        return;
    };
    tcvc.alwaysUseDETwitterCredentials = YES;
    //DETweetTextView *detextView = tcvc.textView;
    //UITextView *textView = (UITextView*)detextView;
    //[textView becomeFirstResponder];
    [viewController presentViewController:tcvc animated:YES completion:nil];
    
    
#if 0
    TweetEditViewController *tweetEditViewController = [[TweetEditViewController alloc] init];
    tweetEditViewController.delegate = self;
    [self presentViewController:tweetEditViewController animated:YES completion:nil];
#endif

}

-(void)fetchTweets:(UIViewController*)viewController tweetsRequest:(TweetsRequest*)tweetsRequest callback:(void (^)(Tweets *tweets))callback
{
    NSString *timeline_url = tweetsRequest.timeline_url;
    
    [self sendHTTPRequestForJSON:timeline_url callback:^(id json){
        if(json == nil){
            callback(nil);
            return;
        }
        NSArray *tweetsArray = [tweetsRequest tweetArrayFromResponseJSONObj:json];
        if(tweetsArray == nil){
            [UIAlertView alertString:@"No tweets found."];
            callback(nil);
            return;
        }
        Tweets *tweets = [[Tweets alloc] initWithJSONArray:tweetsArray];
        callback(tweets);
    }];
}

-(void)sendHTTPRequestForJSON:(NSString*)urlstr callback:(void (^)(id))callback
{
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [auth authorizeRequest:request];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error){
                [UIAlertView alertError:error];
                callback(nil);
                return;
            }
            NSString *response_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(response.statusCode != 200){
                [UIAlertView alertString:response_str];
                callback(nil);
                return;
            }
            NSError *error = nil;
            id json = [NSJSONSerialization JSONObjectWithString:response_str options:0 error:&error];
            if(json == nil){
                [UIAlertView alertError:error];
                callback(nil);
                return;
            }
            callback(json);
        });
    });
}

-(void)fetchUsers:(UIViewController*)viewController usersRequest:(UsersRequest*)usersRequest callback:(void (^)(Users*))callback
{
    NSString *users_url = usersRequest.users_url;
    [self sendHTTPRequestForJSON:users_url callback:^(id json){
        if(json == nil || ![json isKindOfClass:[NSDictionary class]]){
            callback(nil);
            return;
        }
        NSDictionary *dic = json;
        NSArray *ids = dic[@"ids"];

        
        int loop_num = ((ids.count -1) / 100) + 1;
        NSMutableArray *users_array = [[NSMutableArray alloc] init];
        for(int i=0;i<loop_num;i++){
            [users_array addObject:[NSNull null]];
        }
        __block int num_done = 0;
        for(int index=0;index<loop_num;index++){
            int len = MIN(100, ids.count - index*100);
            NSArray *ids100 = [ids subarrayWithRange:NSMakeRange(index*100, len)];
            NSString *ids_str = [ids100 componentsJoinedByString:@","];
            NSString *users_lookup_url = [NSString stringWithFormat:@"https://api.twitter.com/1/users/lookup.json?user_id=%@&include_entities=true", ids_str];
            [self sendHTTPRequestForJSON:users_lookup_url callback:^(id json){
                if(json == nil || ![json isKindOfClass:[NSArray class]]){
                    ;
                }else{
                    NSArray *arr = json;
                    users_array[index] = arr;
                }
                num_done ++;
                if(num_done == loop_num){
                    NSMutableArray *all_array = [[NSMutableArray alloc] init];
                    for(int i=0;i<loop_num;i++){
                        NSArray *arr = users_array[i];
                        if(![arr isKindOfClass:[NSNull class]]){
                            [all_array addObjectsFromArray:arr];
                        }
                    }
                    Users *users = [[Users alloc] initWithJSONArray:all_array];
                    callback(users);
                }
            }];
        }
        
    }];
}
#if 0
-(void)postTweet:(NSString*)text
{
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *encodedText = [GTMOAuthAuthentication encodedOAuthParameterForString:text];
    NSString *body = [NSString stringWithFormat:@"status=%@", encodedText];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [self signIn:^{
        [auth authorizeRequest:request];
        
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(postTweetFetcher:finishedWithData:error:)];
    }];
}
#endif

-(Tweet *)retweet_or_favorite:(NSString*)api_url viewController:(UIViewController*)viewController tweet_id_str:(NSString *)tweet_id_str
{
    NSString *urlstr = [NSString stringWithFormat:@"%@%@.json?include_entities=true",api_url,tweet_id_str];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // [request setValue:nil forHTTPHeaderField:@"Cookie"];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:@"POST"];
    
    [auth authorizeRequest:request];
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(data == nil){
        [UIAlertView alertError:error];
        return nil;
    }
    NSString *response_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"response=%@", response_str);
    if(response.statusCode != 200){
        [UIAlertView alertString:response_str];
        return nil;
    }
    
    
    NSDictionary *json_dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    Tweet *tweet = [[Tweet alloc] initWithDictionary:json_dic];
    return tweet;
}
-(Tweet *)retweet:(UIViewController *)viewController tweet_id_str:(NSString *)tweet_id_str
{
    return [self retweet_or_favorite:@"http://api.twitter.com/1/statuses/retweet/" viewController:viewController tweet_id_str:tweet_id_str];
}
-(Tweet *)favorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str
{
    return [self retweet_or_favorite:@"https://api.twitter.com/1/favorites/create/" viewController:viewController tweet_id_str:tweet_id_str];
}
-(Tweet *)unfavorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str
{
    return [self retweet_or_favorite:@"https://api.twitter.com/1/favorites/destroy/" viewController:viewController tweet_id_str:tweet_id_str];
}



-(Tweet*)destroyTweet:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str
{
    
    NSString *urlstr = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/destroy/%@.json?include_entities=true", tweet_id_str];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:NO];
    [auth authorizeRequest:request];
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(data == nil){
        [UIAlertView alertError:error];
        return nil;
    }
    NSString *response_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(response.statusCode != 200){
        [UIAlertView alertString:response_str];
        return nil;
    }
    
    NSDictionary *json_dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    Tweet *tweet = [[Tweet alloc] initWithDictionary:json_dic];
    return tweet;
    
}
-(Tweet*)getTweet:(NSString*)tweet_id_str
{
    NSString *urlstr = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/show/%@.json?include_entities=true&include_my_retweet=true", tweet_id_str];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [auth authorizeRequest:request];
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(data == nil){
        [UIAlertView alertError:error];
        return nil;
    }
    NSString *response_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(response.statusCode != 200){
        [UIAlertView alertString:response_str];
        return nil;
    }
    
    NSDictionary *json_dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    Tweet *tweet = [[Tweet alloc] initWithDictionary:json_dic];
    return tweet;
    
}
-(void)unretweet:(UIViewController *)viewController tweet_id_str:(NSString*)tweet_id_str
{
    Tweet *tweet = [self getTweet:tweet_id_str];
    if(!tweet){
        return;
    }
    
    NSDictionary *current_user_retweet = [tweet objectForKey:@"current_user_retweet"];
    NSString *current_user_retweet_id_str = [current_user_retweet objectForKey:@"id_str"];
    
    
    [self destroyTweet:viewController tweet_id_str:current_user_retweet_id_str];
    
}
-(void)signOut
{
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:kTwitterKeychainItemName];
    auth = nil;
}

- (NSString*)authPersistenceResponseString
{
    return [auth persistenceResponseString];
}
-(void)setAuthPersistenceResponseString:(NSString *)authPersistenceResponseString
{
    auth = [self getNewAuth];
    [auth setKeysForPersistenceResponseString:authPersistenceResponseString];
}
@end
