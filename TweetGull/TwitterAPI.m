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
- (User*)user
{
    if(auth.userId && auth.screenName){
        User *user = [[User alloc] initWithDictionary:@{@"id_str": auth.userId, @"screen_name": auth.screenName}];
        return user;
    }else{
        return nil;
    }
}
#if 0
- (NSString *)screen_name
{
    return auth.screenName;
}
- (NSString *)user_id
{
    return auth.userId;
}
#endif


- (void)alertHttpResponse:(NSString*)response_str response:(NSHTTPURLResponse *)response
{
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithString:response_str options:0 error:&error];
    NSDictionary *json_dic = nil;
    if([json isKindOfClass:[NSDictionary class]]){
        json_dic = json;
    }
    NSArray *json_errors = nil;
    if(json_dic){
        if([json_dic[@"errors"] isKindOfClass:[NSArray class]]){
            json_errors = json_dic[@"errors"];
        }else if([json_dic[@"error"] isKindOfClass:[NSString class]]){
            json_errors = @[json_dic[@"error"]];
        }
    }
    NSDictionary *json_error;
    if(json_errors && json_errors.count > 0){
        json_error = json_errors[0];
    }
    
    
    
    id rate_limit_limit_obj = response.allHeaderFields[@"X-Rate-Limit-Limit"];
    int rate_limit_limit = -1;
    if([rate_limit_limit_obj isKindOfClass:[NSString class]]){
        rate_limit_limit = [rate_limit_limit_obj intValue];
    }
    id rate_limit_reset_obj = response.allHeaderFields[@"X-Rate-Limit-Reset"];
    int rate_limit_reset = -1;
    if([rate_limit_reset_obj isKindOfClass:[NSString class]]){
        rate_limit_reset = [rate_limit_reset_obj intValue];
    }
    int wait_for = -1;
    if(rate_limit_reset > 0 ){
        wait_for = rate_limit_reset - time(NULL);
    }

    NSString *error_msg = nil;
    if(response.statusCode == 429 && json_error){
        error_msg = [NSString stringWithFormat:@"Twitter: %@ (%d request per 15min). Please wait for %d min %d sec.", json_error[@"message"], rate_limit_limit, wait_for/60, wait_for%60];
    }else if(json_error && [json_error isKindOfClass:[NSString class]]){
        error_msg = [NSString stringWithFormat:@"Error from Twitter: %@", json_error];
    }else{
        error_msg = [NSString stringWithFormat:@"Twitter(Status:%@): %@", response.allHeaderFields[@"Status"], response_str];
    }
    [UIAlertView alertString:error_msg];
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


-(void)composeTweet:(UIViewController*)viewController text:(NSString*)text in_reply_to_status_id_str:(NSString*)in_reply_to_status_id_str callback:(void(^)(bool result))callback
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
        callback(result == DETweetComposeViewControllerResultDone);
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
            NSString *response_str = nil;
            if(data){
                response_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            if(error){
                NSError *error2 = nil;
                id json = nil;
                if(response_str){
                    json = [NSJSONSerialization JSONObjectWithString:response_str options:0 error:&error2];
                }
                if(response_str && json && [json isKindOfClass:[NSDictionary class]] && json[@"error"]){
                    [self alertHttpResponse:response_str response:response];
                }else{
                    [UIAlertView alertError:error];
                }
                callback(nil);
                return;
            }
            if(response.statusCode != 200){
                [self alertHttpResponse:response_str response:response];
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
-(void)lookupUser:(UIViewController*)viewController id_str:(NSString*)id_str callback:(void (^)(User*))callback
{
    NSString *url_str = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/lookup.json?user_id=%@", id_str];
    [self sendHTTPRequestForJSON:url_str callback:^(id json_obj){
        if(![json_obj isKindOfClass:[NSArray class]]){
            callback(nil);
            return;
        }
        NSArray *json_array = json_obj;
        if(json_array.count == 0 || ![json_array[0] isKindOfClass:[NSDictionary class]]){
            callback(nil);
            return;
        }
        NSDictionary *user_dic = json_array[0];
        User *user = [[User alloc] initWithDictionary:user_dic];
        callback(user);
    }];
}

-(void)lookupConnections:(UIViewController*)viewController id_str:(NSString*)id_str callback:(void (^)(NSArray*))callback
{
    NSString *url_str = [NSString stringWithFormat:@"https://api.twitter.com/1.1/friendships/lookup.json?user_id=%@", id_str];
    [self sendHTTPRequestForJSON:url_str callback:^(id json_obj){
        if(![json_obj isKindOfClass:[NSArray class]]){
            callback(nil);
            return;
        }
        NSArray *json_array = json_obj;
        if(json_array.count == 0 || ![json_array[0] isKindOfClass:[NSDictionary class]]){
            callback(nil);
            return;
        }
        NSDictionary *user_dic = json_array[0];
        if(![user_dic[@"connections"] isKindOfClass:[NSArray class]]){
            callback(nil);
            return;
        }
        NSArray *connections = user_dic[@"connections"];
        callback(connections);
    }];
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
            NSString *users_lookup_url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/lookup.json?user_id=%@&include_entities=true", ids_str];
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

-(id)postRequest:(NSString*)url method:(NSString*)method postString:(NSString*)postString viewController:(UIViewController*)viewController
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:method];
    if(postString){
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [auth authorizeRequest:request];
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(data == nil){
        [UIAlertView alertError:error];
        return nil;
    }
    NSString *response_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"===========(%s:response)===============================", __func__);
    NSLog(@"%@", response_str);
    NSLog(@"=======================================================");
    if(response.statusCode != 200){
        [self alertHttpResponse:response_str response:response];
        return nil;
    }
    id json_obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(json_obj == nil){
        [UIAlertView alertError:error];
        return nil;
    }
    return json_obj;
}

#if 0
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

#endif

-(Tweet*)retweet:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str
{
    NSString *url_str = [NSString stringWithFormat: @"https://api.twitter.com/1.1/statuses/retweet/%@.json", tweet_id_str];
    id json_obj = [self postRequest:url_str method:@"POST" postString:nil viewController:viewController];
    if(![json_obj isKindOfClass:[NSDictionary class]]){
        [UIAlertView alertString:@"response is not NSDictinoary"];
        return nil;
    }
    Tweet *tweet = [[Tweet alloc] initWithDictionary:json_obj];
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
-(Tweet *)favorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str;
{
    NSString *url_str = @"https://api.twitter.com/1.1/favorites/create.json";
    NSString *body_str = [NSString stringWithFormat:@"id=%@", tweet_id_str];
    id json_obj = [self postRequest:url_str method:@"POST" postString:body_str viewController:viewController];
    if(![json_obj isKindOfClass:[NSDictionary class]]){
        [UIAlertView alertString:@"response is not NSDictinoary"];
        return nil;
    }
    Tweet *tweet = [[Tweet alloc] initWithDictionary:json_obj];
    return tweet;
}
-(Tweet*)unfavorite:(UIViewController*)viewController tweet_id_str:(NSString*)tweet_id_str
{
    NSString *url_str = @"https://api.twitter.com/1.1/favorites/destroy.json";
    NSString *body_str = [NSString stringWithFormat:@"id=%@", tweet_id_str];
    id json_obj = [self postRequest:url_str method:@"POST" postString:body_str viewController:viewController];
    if(![json_obj isKindOfClass:[NSDictionary class]]){
        [UIAlertView alertString:@"response is not NSDictinoary"];
        return nil;
    }
    Tweet *tweet = [[Tweet alloc] initWithDictionary:json_obj];
    return tweet;
}
-(User*)follow:(UIViewController*)viewController user_id_str:(NSString*)user_id_str
{
    NSString *url_str = @"https://api.twitter.com/1/friendships/create.json";
    // NSString *url_str = @"https://api.twitter.com/1/friendships/create.json";
    NSString *body_str = [NSString stringWithFormat:@"user_id=%@", user_id_str];
    id json_obj = [self postRequest:url_str method:@"POST" postString:body_str viewController:viewController];
    // id json_obj = [self postRequest:url_str postString:@"screen_name=aiueoyoshtstmp2" viewController:viewController];
    //id json_obj = [self postRequest:url_str postString:@"user_id=4" viewController:viewController];
    if(![json_obj isKindOfClass:[NSDictionary class]]){
        [UIAlertView alertString:@"response is not NSDictinoary"];
        return nil;
    }
    User *user = [[User alloc] initWithDictionary:json_obj];
    return user;
}
-(User*)unfollow:(UIViewController*)viewController user_id_str:(NSString*)user_id_str
{
    NSString *url_str = @"https://api.twitter.com/1.1/friendships/destroy.json";
    NSString *body_str = [NSString stringWithFormat:@"user_id=%@", user_id_str];
    id json_obj = [self postRequest:url_str method:@"POST" postString:body_str viewController:viewController];
    if(![json_obj isKindOfClass:[NSDictionary class]]){
        [UIAlertView alertString:@"response is not NSDictinoary"];
        return nil;
    }
    User *user = [[User alloc] initWithDictionary:json_obj];
    return user;
}
-(Tweet*)destroyTweet:(UIViewController *)viewController tweet_id_str:(NSString *)tweet_id_str
{
    NSString *url_str = [NSString stringWithFormat: @"https://api.twitter.com/1.1/statuses/destroy/%@.json", tweet_id_str];
    id json_obj = [self postRequest:url_str method:@"POST" postString:nil viewController:viewController];
    if(![json_obj isKindOfClass:[NSDictionary class]]){
        [UIAlertView alertString:@"response is not NSDictinoary"];
        return nil;
    }
    Tweet *tweet = [[Tweet alloc] initWithDictionary:json_obj];
    return tweet;
}
-(User*)userShow:(UIViewController*)viewController user_id_str:(NSString*)user_id_str
{
    NSString *url_str = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?user_id=%@&include_entities=true", user_id_str];
    id json_obj = [self postRequest:url_str method:@"GET" postString:nil viewController:viewController];
    if(![json_obj isKindOfClass:[NSDictionary class]]){
        [UIAlertView alertString:@"response is not NSDictionary"];
        return nil;
    }
    User *user = [[User alloc] initWithDictionary:json_obj];
    return user;
}
-(Tweet*)getTweet:(NSString*)tweet_id_str
{
    NSString *urlstr = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/show.json?id=%@&include_entities=true&include_my_retweet=true", tweet_id_str];
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
        [self alertHttpResponse:response_str response:response];
        return nil;
    }
    
    NSDictionary *json_dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    Tweet *tweet = [[Tweet alloc] initWithDictionary:json_dic];
    return tweet;
    
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
    // auth.nonce = @"f52523d67d3ed17d4cee53f2ad96f664";
}
@end
