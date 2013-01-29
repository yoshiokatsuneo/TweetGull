//
//  SearchViewController.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 1/28/13.
//  Copyright (c) 2013 Yoshioka Tsuneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController<UISearchBarDelegate,UISearchDisplayDelegate>
-(void)presentFromViewController:(UIViewController*)viewController callback:(void (^)(NSString* search_text))callback;
@end
