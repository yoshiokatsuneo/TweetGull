//
//  Misc.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 1/28/13.
//  Copyright (c) 2013 Yoshioka Tsuneo. All rights reserved.
//

#import "Misc.h"
#import "TwitterAPI.h"
#import "BlocksKit.h"

@implementation Misc
+(void)askToTweetAboutInstallation:(UIViewController*)viewController twitterAPI:(TwitterAPI*)twitterAPI
{
    BOOL askedToTweetAboutInstallation = [[NSUserDefaults standardUserDefaults] boolForKey:@"askedToTweetAboutInstallation"];
    if(askedToTweetAboutInstallation){
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"askedToTweetAboutInstallation"];
    
    NSString *model = [UIDevice currentDevice].model;
    
    // NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    NSString *text = [NSString stringWithFormat:@"I just installed TweetGull %@ on my %@. It automatically pre-load linked web page before I tap it! https://itunes.apple.com/us/app/tweetgull/id590568947?mt=8", shortVersion, model];
    NSString *text_with_quote = [NSString stringWithFormat:@"\"%@\"", text];
    
    [UIAlertView showAlertViewWithTitle:@"Do you tweet about TweetGull like below ?" message:text_with_quote cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:@[NSLocalizedString(@"Yes", nil)] handler:^(UIAlertView *alertView, NSInteger result) {
        if(result == 1){
            [twitterAPI postTweet:viewController text:text];
        }
    }];
}
+(void)askToFollowTweetGull:(UIViewController*)viewController twitterAPI:(TwitterAPI*)twitterAPI callback:(void (^)(void))callback
{
    User * user = [twitterAPI userShow:viewController user_id_str:@"760178030" /* "tweetgull" */];
    NSNumber * following_status = user[@"following"];
    BOOL following_status_bool = [following_status isKindOfClass:[NSNumber class]] && following_status.boolValue;
    if(following_status_bool == NO){
        [UIAlertView showAlertViewWithTitle:@"Do you follow @tweetgull ?" message:nil cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:@[NSLocalizedString(@"Yes", nil)] handler:^(UIAlertView *alertView, NSInteger result){
            if(result == 1){
                [twitterAPI follow:viewController user_id_str:@"760178030" /* "tweetgull" */];
            }
            if(callback){
                callback();
            }
        }];
    }else{
        if(callback){
            callback();
        }
    }
}
@end

