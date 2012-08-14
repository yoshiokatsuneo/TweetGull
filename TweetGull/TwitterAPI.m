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

static NSString *const kTwitterKeychainItemName = @"TwitterTest1";
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
- (NSString*)percentEncodeString:(NSString*)string
{
    return (__bridge_transfer NSString*) CFURLCreateStringByAddingPercentEscapes(NULL,  (__bridge CFStringRef)string, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
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
        [signInViewController.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSLog(@"auth=%@", auth);
    NSLog(@"auth2=%@", auth2);
    auth = auth2;
    //[self dismissModalViewControllerAnimated:YES];
    [signInViewController.navigationController popViewControllerAnimated:YES];
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

    UINavigationController *navigationController = viewController.navigationController;
    [navigationController pushViewController:authViewController animated:YES];
    
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
-(void)fetchTweets:(UIViewController*)viewController user_screen_name:(NSString*)user_screen_name search_query:(NSString*)search_query callback:(void (^)(Tweets *tweets))callback
{
    // NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://api.twitter.com/1/statuses/public_timeline.json"]];
    NSString *timeline_url = nil;
    if(user_screen_name){
        timeline_url = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/user_timeline.json?screen_name=%@&", user_screen_name];
        search_query = nil;
    }else if(search_query){
        timeline_url = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@&rpp=100&include_entities=true&result_type=mixed", [self percentEncodeString:search_query]];
    }else{
        timeline_url = @"http://api.twitter.com/1/statuses/home_timeline.json?";
    }
    timeline_url = [timeline_url stringByAppendingString:@"count=200&include_entities=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:timeline_url]];
    // NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json?count=200&include_entities=1"]];
    // NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/statuses/public_timeline.json"]];
    [self signIn:viewController callback:^{
        [auth authorizeRequest:request];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(data == nil){
                    [UIAlertView alertError:error];
                    callback(nil);
                    return;
                }
                NSString *response_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if(search_query){
                    NSError *error;
                    NSDictionary *json_dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                    NSArray *json_array = [json_dic objectForKey:@"results"];
                    NSData *json_data = [NSJSONSerialization dataWithJSONObject:json_array options:NSJSONWritingPrettyPrinted error:&error];
                    response_str = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
                }
                Tweets *tweets = [[Tweets alloc] initWithJSONString:response_str];
                callback(tweets);
            });
        });
        
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
@end
